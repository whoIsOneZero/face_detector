import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:face_camera/face_camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FaceCamera.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? _capturedImage;
  late FaceCameraController controller;

  @override
  void initState() {
    controller = FaceCameraController(
      autoCapture: true,
      defaultCameraLens: CameraLens.front,
      onCapture: (File? image) {
        setState(() => _capturedImage = image);
      },
      onFaceDetected: (Face? face) {
        // Debugging: print face detection details
        if (kDebugMode) {
          print("Face detected: ${face != null}");
        }
        if (face != null) {
          if (kDebugMode) {
            print("Well positioned: ${face.boundingBox}");
          }
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Detector App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Face Detector'),
          ),
          body: Builder(builder: (context) {
            if (_capturedImage != null) {
              return Center(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.file(
                      _capturedImage!,
                      width: double.maxFinite,
                      fit: BoxFit.fitWidth,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await controller.startImageStream();
                          setState(() => _capturedImage = null);
                        },
                        child: const Text(
                          'Capture Again',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ))
                  ],
                ),
              );
            }
            return Stack(children: [
              SmartFaceCamera(
                  controller: controller,
                  indicatorShape: IndicatorShape.square,
                   /*indicatorBuilder: (context, face, size) {
                  // Optional: Customize the face indicator
                       return CustomPaint(
                    painter: FacePainter(
                      face: face.face,
                      indicatorShape: IndicatorShape.square, // Or other shapes
                      imageSize: size,
                    ),
                  );
                },*/
                  messageBuilder: (context, face) {
                    if (face == null) {
                      return _message('Place your face in the camera');
                    }
                    if (!face.wellPositioned) {
                      return _message('Center your face in the square');
                    }
                    return const SizedBox.shrink();
                  }),
                  //_faceOverlay(),
            ]);
          })),
    );
  }

  Widget _message(String msg) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
        child: Text(msg,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, height: 1.5, fontWeight: FontWeight.w400)),
      );

  Widget _faceOverlay() => Positioned.fill(
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
