import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imagetoframe/controller/conversationcontroller.dart';
import 'package:imagetoframe/controller/loadingscreen.dart';
import 'package:imagetoframe/screens/login.dart';
import 'package:imagetoframe/service/local_storage_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

class ConversationWithBot extends ConsumerStatefulWidget {
  const ConversationWithBot({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConversationWithBotState();
}

class _ConversationWithBotState extends ConsumerState<ConversationWithBot> {
  final ScrollController _scrollController = ScrollController();
  final LocalStorageService _localStorageService = LocalStorageService();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await getConversations(ref);
    });
  }

  File? videoFile;
  final picker = ImagePicker();
  File? galleryFile;

  Future<http.StreamedResponse> getDataFromAPi(String videoPath) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://192.168.1.102:8081/api/video'));
    request.files.add(await http.MultipartFile.fromPath('video', videoPath));

    http.StreamedResponse response = await request.send();
    return response;
  }

  Future<void> uploadingConversation(String videoPath) async {
    changeLoaderState(ref, true);
    var response = await getDataFromAPi(videoPath);
    if (response.statusCode == 200) {
      String data = await response.stream.bytesToString();
      //pass the string from data in place of "comming soon"
      await addConversation(ref, videoPath, data ?? 'unable to translate');
    } else {
      changeLoaderState(ref, false);
      showSnackBar(
          "error backend is giving status code of ${response.statusCode}");
    }
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  getVideo(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getVideo(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showNothingSnackBar() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Nothing is selected')));
  }

  void showSnackBar(String issue) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(issue)));
  }

  Future<bool> showConfirmationDialog(
      BuildContext context, String title, String content) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            GestureDetector(
              child: const Text(
                'No',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.of(context).pop(false);
              },
            ),
            GestureDetector(
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future getVideo(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickVideo(
        source: img,
        preferredCameraDevice: CameraDevice.front,
        maxDuration: const Duration(minutes: 2));
    XFile? xfilePick = pickedFile;

    if (xfilePick != null) {
      galleryFile = File(pickedFile!.path);
      uploadingConversation(pickedFile.path);
    } else {
      showNothingSnackBar();
    }
  }

  void logout() async {
    bool logout = await showConfirmationDialog(
        context, "Logout", "Do you want to logout?");
    if (logout) {
      _localStorageService.removeCredentail();
      navigateToLogin();
    }
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    return WillPopScope(
      onWillPop: () async {
        bool allowBackNavigation = await showConfirmationDialog(
            context, 'Exit Application', 'Do you want to exit application?');
        return allowBackNavigation;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Deaf converter AI"),
          centerTitle: true,
          actions: [
            IconButton(onPressed: logout, icon: const Icon(Icons.exit_to_app))
          ],
        ),
        body: Stack(
          children: [
            ListView(
              controller: _scrollController,
              children: ref.watch(conversationData).isEmpty
                  ? [
                      const Text(
                          "Start by pressing the upload button at bottom right")
                    ]
                  : ref
                      .watch(conversationData)
                      .map((data) => showConversation(data))
                      .toList(),
            ),
            Visibility(
                visible: ref.watch(conversationLoader),
                child: const LoadingScreen()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            if (!ref.watch(conversationLoader)) {
              Permission.storage.request().then((status) {
                if (status.isGranted) {
                  _showPicker();
                }
              });
            }
          },
          child: const Icon(
            Icons.upload,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget showConversation(Conversation data) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 160.w,
              height: 200.h,
              margin: EdgeInsets.only(right: 5.w, top: 10.h),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.r))),
              child: VideoPlayerWidget(videoLink: data.video),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.only(left: 5.w, top: 10.h),
              width: 250.w,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(10.r))),
              child: Text(
                data.answer,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key, required this.videoLink});

  final String videoLink;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool error = false;

  @override
  void initState() {
    super.initState();
    // _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoLink))
    _controller = VideoPlayerController.file(File(widget.videoLink))
      ..initialize().then((_) {
        setState(() {});
        _controller!.addListener(completedListener);
      }).onError((error, stackTrace) {
        print("Video initialization error: $error");
        setState(() {
          error = true;
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  void stopAndPlayVideo() {
    setState(() {
      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
    });
  }

  void completedListener() {
    if (_controller!.value.isCompleted) {
      setState(() {
        _controller!.pause();
        _controller!.seekTo(Duration.zero);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller!.value.isInitialized
        ? !error
            ? Stack(
                children: [
                  VideoPlayer(_controller!),
                  Center(
                    child: IconButton(
                        onPressed: stopAndPlayVideo,
                        icon: Icon(
                          _controller!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        )),
                  )
                ],
              )
            : const SizedBox(
                child: Text("video is not playable maybe Deleted or removed"),
              )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
