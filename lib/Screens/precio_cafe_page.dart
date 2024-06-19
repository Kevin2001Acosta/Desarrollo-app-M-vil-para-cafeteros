import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PrecioCafe extends StatelessWidget {
  const PrecioCafe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 131, 155, 42),
        title: const Text(
          'PRECIO DEL CAFÉ',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: const Center(child: PdfDownloadScreen()),
    );
  }
}

class PdfDownloadScreen extends StatefulWidget {
  const PdfDownloadScreen({super.key});

  @override
  PdfDownloadScreenState createState() => PdfDownloadScreenState();
}

class PdfDownloadScreenState extends State<PdfDownloadScreen> {
  String fileurl =
      "https://federaciondecafeteros.org/app/uploads/2019/10/precio_cafe.pdf";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),
        body: Center(
            child: Container(
          margin: const EdgeInsets.only(right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AutoSizeText(
                "Si quieres saber el precio del café actualizado,\n ¡Descarga el PDF!\n ⬇️",
                style: TextStyle(
                  color: Colors.black,
                ),
                maxLines: 3,
                minFontSize: 21.0,
                maxFontSize: 25.0,
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: () async {
                  var connectivityResult =
                      await Connectivity().checkConnectivity();
                  if (connectivityResult[0] == ConnectivityResult.none) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: AutoSizeText(
                        "No tienes conexión a internet, prueba en otro momento.",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        maxLines: 3,
                        minFontSize: 20.0,
                        maxFontSize: 25.0,
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ));
                  } else {
                    Map<Permission, PermissionStatus> statuses = await [
                      Permission.storage,
                    ].request();

                    if (statuses[Permission.storage]!.isGranted) {
                      var dir = await getDownloadsDirectory();

                      if (dir != null) {
                        String savename = "PrecioCafe.pdf";
                        String savePath = '${dir.path}/$savename';

                        try {
                          await Dio().download(fileurl, savePath,
                              onReceiveProgress: (received, total) {
                            if (total != -1) {
                              print(
                                  (received / total * 100).toStringAsFixed(0) +
                                      "%");
                            }
                          });
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: AutoSizeText(
                              "Archivo Descargado Exitosamente en la dirección: $dir",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              maxLines: 3,
                              minFontSize: 20.0,
                              maxFontSize: 25.0,
                              textAlign: TextAlign.center,
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 131, 155, 42),
                            duration: Duration(seconds: 3),
                          ));
                          OpenFile.open(savePath);
                        } on DioError catch (e) {
                          print(e.message);
                        }
                      }
                    } else {
                      print(
                          "No se dieron los permisos necesarios para leer archivos, por favor intentelo de nuevo.");
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: AutoSizeText(
                          "Permiso Denegado, por favor intentelo de nuevo.",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          maxLines: 3,
                          minFontSize: 20.0,
                          maxFontSize: 25.0,
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                  textStyle: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                child: const Text("DESCARGAR ARCHIVO"),
              )
            ],
          ),
        )));
  }
}
