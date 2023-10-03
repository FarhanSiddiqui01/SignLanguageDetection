import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imagetoframe/screens/splashscreen.dart';

import 'firebase_options.dart';

const primaryColor = Color(0XFF121C7B);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );

  runApp(ScreenUtilInit(
      designSize: const Size(366, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ProviderScope(
            child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sign Language Detection',
          home: const SplashScreen(),
          theme: ThemeData(
              primarySwatch: MaterialColor(primaryColor.value, <int, Color>{
                50: primaryColor.withOpacity(0.1),
                100: primaryColor.withOpacity(0.2),
                200: primaryColor.withOpacity(0.3),
                300: primaryColor.withOpacity(0.4),
                400: primaryColor.withOpacity(0.5),
                500: primaryColor.withOpacity(0.6),
                600: primaryColor.withOpacity(0.7),
                700: primaryColor.withOpacity(0.8),
                800: primaryColor.withOpacity(0.9),
                900: primaryColor.withOpacity(1.0),
              }),
              primaryColor: const Color(0XFF121C7B)),
        ));
      }));
}

//important

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   List<File> frameFilesHere = [];

//   bool loading = false;

//   File? videoFile;
//   final picker = ImagePicker();
//   File? galleryFile;

//   Future<void> getImages(String outputPath, int length) async {
//     List<File> frameFiles = [];
//     Directory dir = Directory(outputPath);
    // for (var i = 1; i < length; i++) {
    //   frameFiles.add(
    //     File('${outputPath}${(i > 9 ? "00" : "000") + i.toString()}.png'),
    //   );
    // }
//     await for (var entity in dir.list()) {
//       if (entity is File && entity.path.endsWith('.png')) {
//         frameFiles.add(entity);
//       }
//     }
//     setState(() {
//       frameFilesHere = frameFiles;
//     });
//   }

//   Future<void> createDirectory(String outputPath) async {
//     Directory dir = Directory(outputPath);
//     if (!await dir.exists()) {
//       dir.create();
//     }
//   }

//   Future clearDirectory(String path) async {
//     Directory dir = Directory(path);
//     await for (var entity in dir.list()) {
//       if (entity is File && entity.path.endsWith('.png')) {
//         await entity.delete();
//       }
//     }
//   }

//   Future<void> extractImages(String videoPath) async {
//     setState(() {
//       loading = true;
//     });
//     const String basePath = "/storage/emulated/0/Download/";
//     //const String inputPath = "${basePath}work.mp4";
//     const String outputPath = "${basePath}symbolRecog/";
//     await createDirectory(outputPath);
//     String commandExecute = "-i $videoPath -vf fps=1 $outputPath%4d.png";
//     await clearDirectory(outputPath);

//     FFmpegKit.execute(commandExecute).then((session) async {
//       final returnCode = await session.getReturnCode();

//       if (ReturnCode.isSuccess(returnCode)) {
//         var dir = Directory(outputPath);
//         int length = await dir.list().length;
//         print(length);
//         getImages(outputPath, length);
//         // setState(() {
//         //   frameFilesHere = await getImages(outputPath, length);
//         // });
//       } else if (ReturnCode.isCancel(returnCode)) {
//         // CANCEL
//       } else {
//         // ERROR
//       }
//       setState(() {
//         loading = false;
//       });
//     });
//   }

//   void _showPicker({
//     required BuildContext context,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () {
//                   getVideo(ImageSource.gallery);
//                   Navigator.of(context).pop();
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_camera),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   getVideo(ImageSource.camera);
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future getVideo(
//     ImageSource img,
//   ) async {
//     final pickedFile = await picker.pickVideo(
//         source: img,
//         preferredCameraDevice: CameraDevice.front,
//         maxDuration: const Duration(minutes: 2));
//     XFile? xfilePick = pickedFile;

//     setState(
//       () {
//         if (xfilePick != null) {
//           galleryFile = File(pickedFile!.path);
//           extractImages(pickedFile.path);
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
//               const SnackBar(content: Text('Nothing is selected')));
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Video to Frames'),
//       ),
//       body: Column(
//         children: [
//           Center(
//             child: ElevatedButton(
//               onPressed: () async {
//                 if (await Permission.storage.request().isGranted) {
//                   _showPicker(context: context);
//                 } else {
//                   await Permission.storage.request();
//                 }
//               },
//               child: const Text('Extract Frames'),
//             ),
//           ),
//           (loading)
//               ? const CircularProgressIndicator()
//               : (frameFilesHere.isNotEmpty)
//                   ? FrameListPage(frameFilesHere)
//                   : const Text("no video selected")
//         ],
//       ),
//     );
//   }
// }

// class FrameListPage extends StatelessWidget {
//   final List<File> frames; // List of frame files

//   const FrameListPage(this.frames, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: ListView.builder(
//         shrinkWrap: true,
//         itemCount: frames.length,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Image.file(
//               frames[index],
//               width: 200,
//               height: 200,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
