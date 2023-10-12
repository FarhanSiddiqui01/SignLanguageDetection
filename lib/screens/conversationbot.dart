import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imagetoframe/controller/conversationcontroller.dart';
import 'package:imagetoframe/controller/loadingscreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class ConversationWithBot extends ConsumerStatefulWidget {
  const ConversationWithBot({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConversationWithBotState();
}

class _ConversationWithBotState extends ConsumerState<ConversationWithBot> {
  final ScrollController _scrollController = ScrollController();
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

  Future<void> getImages(String outputPath) async {
    List<File> frameFiles = [];
    Directory dir = Directory(outputPath);

    await for (var entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.png')) {
        frameFiles.add(entity);
      }
    }
  }

  Future<void> createDirectory(String outputPath) async {
    Directory dir = Directory(outputPath);
    if (!await dir.exists()) {
      dir.create();
    }
  }

  Future clearDirectory(String path) async {
    Directory dir = Directory(path);
    int lenght = await dir.list().length;
    if (lenght > 5) {
      await for (var entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.png')) {
          await entity.delete();
        }
      }
    }
  }

  Future<void> extractImages(String videoPath) async {
    changeLoaderState(ref, true);
    const String basePath = "/storage/emulated/0/Download/";
    const String outputPath = "${basePath}symbolRecog/";
    await createDirectory(outputPath);
    String commandExecute = "-i $videoPath -vf fps=1 $outputPath%4d.png";
    await clearDirectory(outputPath);

    FFmpegKit.execute(commandExecute).then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        await getImages(outputPath);
        await addConversation(ref, videoPath, "comming soon");
      } else if (ReturnCode.isCancel(returnCode)) {
        // CANCEL
      } else {
        // ERROR
      }
    });
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
      extractImages(pickedFile.path);
    } else {
      showNothingSnackBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Deaf converter AI"),
        centerTitle: true,
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
        onPressed: () async {
          if (!ref.watch(conversationLoader)) {
            if (await Permission.storage.request().isGranted) {
              _showPicker();
            } else {
              await Permission.storage.request();
            }
          }
        },
        child: const Icon(
          Icons.upload,
          color: Colors.white,
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

  @override
  void initState() {
    super.initState();
    // _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoLink))
    _controller = VideoPlayerController.file(File(widget.videoLink))
      ..initialize().then((_) {
        setState(() {});
        _controller!.addListener(completedListener);
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
            child: Text("video is not playable maybe Deleted"),
          );
  }
}
