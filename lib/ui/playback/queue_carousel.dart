import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;

/// Keeps the visible page in sync with playback, including automatic advances.
class QueueCarousel extends StatefulWidget {
  const QueueCarousel({
    super.key,
    required this.index,
    required this.itemCount,
    required this.height,
    required this.itemBuilder,
    required this.onManualPage,
  });
  final int index;
  final int itemCount;
  final double height;
  final Widget Function(BuildContext, int) itemBuilder;
  final ValueChanged<int> onManualPage;

  @override
  State<QueueCarousel> createState() => _QueueCarouselState();
}

class _QueueCarouselState extends State<QueueCarousel> {
  final controller = CarouselSliderController();

  @override
  void didUpdateWidget(QueueCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && controller.ready && widget.index < widget.itemCount) {
          controller.jumpToPage(widget.index);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => CarouselSlider.builder(
    carouselController: controller,
    itemCount: widget.itemCount,
    itemBuilder: (context, index, _) => widget.itemBuilder(context, index),
    options: CarouselOptions(
      viewportFraction: 1,
      initialPage: widget.index,
      height: widget.height,
      enlargeCenterPage: true,
      enlargeStrategy: CenterPageEnlargeStrategy.height,
      enlargeFactor: 0.5,
      enableInfiniteScroll: false,
      scrollPhysics: const BouncingScrollPhysics(),
      onPageChanged: (index, reason) {
        if (reason == CarouselPageChangedReason.manual &&
            index != widget.index) {
          widget.onManualPage(index);
        }
      },
    ),
  );
}
