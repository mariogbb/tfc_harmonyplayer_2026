import 'package:cast/cast.dart';
import 'package:flutter/material.dart';
import 'package:player/services/cast/cast_service.dart';

class GoogleCastDialogs {
  static void listAvaliableCasts(BuildContext context) {
    CastService service = CastService();

    Future<List<CastDevice>> getDevices =
        service.searchCastDevices(const Duration(seconds: 5));

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.white54,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 50),
                    child: FutureBuilder<List<CastDevice>>(
                      future: getDevices,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<CastDevice> devices = snapshot.data!;

                          if (devices.isEmpty) {
                            return ListTile(
                              title: Text(
                                "No devices found",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .unselectedWidgetColor,
                                    ),
                              ),
                            );
                          }

                          return ListView(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            children: [
                              const ListTile(
                                title: Text(
                                  "Avaliable devices:",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: devices.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {},
                                    child: ListTile(
                                      leading: const Icon(Icons.smartphone),
                                      title: Text(devices[index].name),
                                    ),
                                  );
                                },
                              )
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return const ListTile(
                            title: Center(
                              child: Text("Error searching for devices"),
                            ),
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
