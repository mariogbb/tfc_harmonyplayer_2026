import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:player/screens/welcome_screen/welcome_entry.dart';

List welcomeSlideWidgets = [
  const WelcomeEntry(
      title: "Bienvenid@",
      description: "Este es un reproductor de música",
      imageAsset: "assets/wellcome_screen/1.png"),
  const WelcomeEntry(
      title: "Escucha canciones",
      description:
          "Disfruta de playlists creadas con recomendaciones para tí y listas de canciones más escuchadas",
      imageAsset: "assets/wellcome_screen/1.png"),
  WelcomeEntry(
      title: "Permisos necesarios",
      description:
          "Para poder escuchar música la aplicación necesita leer las canciones desde el almacenamiento",
      optionalWidget: TextButton(
          onPressed: () async {
            List<Permission> req = [];

            var state = await Permission.storage.status;

            if (state.isDenied) {
              req.add(Permission.storage);
            }

            state = await Permission.manageExternalStorage.status;

            if (state.isDenied) {
              req.add(Permission.manageExternalStorage);
            }

            await req.request();
          },
          child: const Text("Permitir")),
      imageAsset: "assets/wellcome_screen/1.png")
];
