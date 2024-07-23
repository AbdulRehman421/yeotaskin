import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_colors.dart';

import '../../../utilities/app_fonts.dart';
import '../../../utilities/snackbar_utils.dart';

class ViewVideoScreen extends StatefulWidget {
  final String videoUrl;
  const ViewVideoScreen({super.key, required this.videoUrl});

  @override
  State<ViewVideoScreen> createState() => _ViewVideoScreenState();
}

class _ViewVideoScreenState extends State<ViewVideoScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _showPlayButton = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse("https://${widget.videoUrl}"))
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
        _controller.play();

        _controller.addListener(() {
          if (_controller.value.duration == _controller.value.position &&
              _controller.value.duration != Duration.zero) {
            setState(() {
              _showPlayButton = true;
            });
          } else {
            setState(() {
              _showPlayButton = false;
            });
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    print(_controller);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        surfaceTintColor: AppColors.backgroundColor,
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'Video Player',
          style: TextStyle(
            fontFamily: AppFonts.palatino,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Center(
        child: _isVideoInitialized
            ? SingleChildScrollView(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 9 / 16,
                      child: VideoPlayer(_controller),
                    ),
                    if (_showPlayButton)
                      Center(
                        child: IconButton(
                            onPressed: () {
                              _controller.play();
                            },
                            icon: const Icon(
                              Icons.play_circle,
                              size: 80,
                              color: AppColors.primaryColor,
                            )),
                      ),
                    !loading
                        ? Positioned(
                            right: 0,
                            bottom: 10,
                            child: TextButton(
                                onPressed: () {
                                  _downloadPdf();
                                },
                                child: const Icon(
                                  Icons.download,
                                  size: 40,
                                  color: Colors.white,
                                )),
                          )
                        : Positioned(
                            right: 0,
                            bottom: 10,
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _downloadPdf() async {
    setState(() {
      loading = true;
    });

    try {
      Dio dio = Dio();
      String appDownloadPath =
          await ExternalPath.getExternalStoragePublicDirectory(
              ExternalPath.DIRECTORY_DOWNLOADS);
      List fileNameList = widget.videoUrl.split("/");
      String fileName = fileNameList.elementAt(fileNameList.length - 1);
      String filePath = '$appDownloadPath/Yeotaskin/$fileName';

      await dio.download("https://${widget.videoUrl}", filePath);

      SnackBarUtils.show(
          title: 'File downloaded to: $filePath', isError: false, duration: 3);
      if (kDebugMode) {
        print("File downloaded to: $filePath");
      }
    } catch (e) {
      SnackBarUtils.show(
          title: 'Something went wrong while downloading!', isError: true);
      if (kDebugMode) {
        print("Error downloading PDF: $e");
      }
    }

    setState(() {
      loading = false;
    });
  }
}
