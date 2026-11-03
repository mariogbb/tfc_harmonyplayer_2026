import 'package:flutter/material.dart';
import 'package:player/ui/welcome/welcome_entries.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key, required this.onWellcomeClose})
    : super(key: key);

  final VoidCallback onWellcomeClose;

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  double currentPage = 0.0;

  final _pageViewController = PageController();

  @override
  void initState() {
    super.initState();
    _pageViewController.addListener(() {
      setState(() => currentPage = _pageViewController.page ?? 0.0);
    });
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  List<Widget> indicator() => List<Widget>.generate(
    welcomeSlideWidgets.length,
    (index) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 3.0),
      height: 10.0,
      width: 10.0,
      decoration: BoxDecoration(
        color: currentPage.round() == index
            ? Theme.of(context).primaryColor
            : Theme.of(context).primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView.builder(
            controller: _pageViewController,
            itemCount: welcomeSlideWidgets.length,
            itemBuilder: (BuildContext context, int index) {
              return welcomeSlideWidgets[index];
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 70.0),
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: indicator(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: CircleAvatar(
                backgroundColor:
                    (currentPage <
                        (welcomeSlideWidgets.length.toDouble() - 1.5))
                    ? Theme.of(context).unselectedWidgetColor
                    : Theme.of(context).primaryColor,
                child: IconButton(
                  onPressed: widget.onWellcomeClose,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
