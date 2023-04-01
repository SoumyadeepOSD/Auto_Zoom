// import 'package:adv_camera/adv_camera.dart';
// import 'package:flutter/material.dart';

// void main() {
//   String id = DateTime.now().toIso8601String();
//   runApp(MaterialApp(home: MyApp(id: id)));
// }

// class MyApp extends StatefulWidget {
//   final String id;

//   const MyApp({Key? key, required this.id}) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//       ),
//       body: Center(child: Text('Press Floating Button to access camera')),
//       floatingActionButton: FloatingActionButton(
//         heroTag: "test3",
//         child: Icon(Icons.camera),
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (BuildContext context) {
//                 String id = DateTime.now().toIso8601String();
//                 return CameraApp(id: id);
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class CameraApp extends StatefulWidget {
//   final String id;

//   const CameraApp({Key? key, required this.id}) : super(key: key);

//   @override
//   _CameraAppState createState() => _CameraAppState();
// }

// class _CameraAppState extends State<CameraApp> {
//   List<String> pictureSizes = <String>[];
//   String? imagePath;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('AdvCamera Example'),
//       ),
//       body: SafeArea(
//         child: AdvCamera(
//           initialCameraType: CameraType.rear,
//           onCameraCreated: _onCameraCreated,
//           onImageCaptured: (String path) {
//             if (this.mounted)
//               setState(() {
//                 imagePath = path;
//               });
//           },
//           cameraPreviewRatio: CameraPreviewRatio.r16_9,
//           focusRectColor: Colors.purple,
//           focusRectSize: 200,
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         heroTag: "capture",
//         child: Icon(Icons.camera),
//         onPressed: () {
//           cameraController!.captureImage();
//         },
//       ),
//     );
//   }

//   AdvCameraController? cameraController;

//   _onCameraCreated(AdvCameraController controller) {
//     this.cameraController = controller;

//     this.cameraController!.getPictureSizes().then((pictureSizes) {
//       setState(() {
//         this.pictureSizes = pictureSizes ?? <String>[];
//       });
//     });
//   }
// }
//===========================================================
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// List<CameraDescription> cameras = [];

// Future<void> main() async {
//   // Initialize cameras
//   WidgetsFlutterBinding.ensureInitialized();
//   cameras = await availableCameras();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Autozoom Camera Demo',
//       home: AutozoomCamera(),
//     );
//   }
// }

// class AutozoomCamera extends StatefulWidget {
//   @override
//   _AutozoomCameraState createState() => _AutozoomCameraState();
// }

// class _AutozoomCameraState extends State<AutozoomCamera> {
//   late CameraController _controller;
//   double _zoomLevel = 1.0;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize camera controller
//     _controller = CameraController(cameras[0], ResolutionPreset.medium);
//     _controller.initialize().then((_) {
//       if (!mounted) {
//         return;
//       }
//       setState(() {});
//       // Start autozoom functionality
//       _controller.startImageStream((CameraImage image) {
//         setState(() {
//           _zoomLevel = calculateZoomLevel(image);
//           _controller.setZoomLevel(_zoomLevel);
//         });
//       });
//     });
//   }

//   double calculateZoomLevel(CameraImage image) {
//     // Calculate the average brightness of the image
//     var totalBrightness = 0.0;
//     for (var plane in image.planes) {
//       for (var i = 0; i < plane.bytes.length; i++) {
//         totalBrightness += plane.bytes[i];
//       }
//     }
//     var avgBrightness = totalBrightness / (image.width * image.height);

//     // Calculate the zoom level based on the average brightness
//     var zoomLevel = (avgBrightness / 255) * 2;
//     if (zoomLevel < 1.0) {
//       zoomLevel = 1.0;
//     } else if (zoomLevel > 10.0) {
//       zoomLevel = 10.0;
//     }
//     return zoomLevel;
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_controller.value.isInitialized) {
//       return Container();
//     }
//     return AspectRatio(
//       aspectRatio: _controller.value.aspectRatio,
//       child: CameraPreview(_controller),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  bool isReady = false;
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        isReady = true;
      });
      controller.startImageStream((CameraImage image) {
        setState(() {
          _zoomLevel = calculateZoomLevel(image);
          controller.setZoomLevel(_zoomLevel);
        });
      });
    });
  }

  Future<void> _takePicture() async {
    try {
      // Ensure that the camera is initialized.

      // Attempt to take a picture and get the file `imageFile`.
      final XFile imageFile = await controller.takePicture();

      // Save the file to the gallery.
      final result = await ImageGallerySaver.saveFile(imageFile.path);

      // If the file was saved successfully, show a snackbar with the success message.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Picture saved to gallery!'),
      ));
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  double calculateZoomLevel(CameraImage image) {
    var totalBrightness = 0.0;
    for (var plane in image.planes) {
      for (var i = 0; i < plane.bytes.length; i++) {
        totalBrightness += plane.bytes[i];
      }
    }
    var avgBrightness = totalBrightness / (image.width * image.height);
    var zoomLevel = (avgBrightness / 255) * 2;
    if (zoomLevel < 1.0) {
      zoomLevel = 1.0;
    } else if (zoomLevel > 10.0) {
      zoomLevel = 10.0;
    }
    return zoomLevel;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<String?> captureImage() async {
    if (!controller.value.isInitialized) {
      return null;
    }

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String filePath =
        '${appDirectory.path}/image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final XFile imageFile = await controller.takePicture();
    final result = await ImageGallerySaver.saveFile(imageFile.path);

    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady && !controller.value.isInitialized) {
      return Container();
    }

    return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Column(
          children: [
            CameraPreview(controller),
          ],
        ));
  }
}
