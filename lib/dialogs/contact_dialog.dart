import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDialog {
  static void showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.white54,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  "Email: ",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Uri mailTo =
                      Uri(scheme: "mailto", path: "mario.besada.dev@gmail.com");

                  launchUrl(mailTo);
                },
                child: const ListTile(
                  leading: Icon(Icons.mail),
                  title: Text("mario.besada.dev@gmail.com"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
