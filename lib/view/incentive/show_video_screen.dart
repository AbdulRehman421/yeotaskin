import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/view/incentive/widgets/team_list.dart';

import '../../APIs/urls.dart';
import '../../models/home_model.dart';
import '../../models/profile_model.dart';
import '../../services/user_profile_manager.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  ProfileModel profile = UserProfileManager().profile;

  bool _isVideoInitialized = false;
  bool salesLoading = false;
  List teamSalesList = [];
  List<String> topUplineList = [];
  List upline = [];
  List names = [];
  final double tableRowHeight = 50;

  int _currentIndex = 0;
  Timer? _timer = Timer(const Duration(milliseconds: 500), () {});

  final ScrollController _scrollController = ScrollController();

  void setLoading(bool status) {
    if (mounted) {
      setState(() {
        salesLoading = status;
      });
    }
  }

  Future<void> getTeamSales() async {
    setLoading(true);
    ProfileModel profile = UserProfileManager().profile;
    try {
      final response =
          await http.get(Uri.parse("${URLs.baseURL}${URLs.teamSalesURL}"));

      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        if (jsonDecode(response.body)['data'] != null) {
          teamSalesList = jsonDecode(response.body)['data'];

          for (int i = 0; i < teamSalesList.length - 1; i++) {
            for (int j = i + 1; j < teamSalesList.length; j++) {
              if (int.parse(teamSalesList[i]['total_sales'].toString()) <
                  int.parse(teamSalesList[j]['total_sales'].toString())) {
                Map<String, dynamic> temp = teamSalesList[i];
                teamSalesList[i] = teamSalesList[j];
                teamSalesList[j] = temp;
              }
            }
          }
          if (kDebugMode) {
            print(teamSalesList);
          }
          if (teamSalesList.length < 3) {
            teamSalesList.map((e) {
              if (kDebugMode) {
                print("<3: ${e['upline']}");
              }
              topUplineList.add(e['upline'].toString());
            }).toList();
          } else {
            if (kDebugMode) {
              print(">3: ${teamSalesList[0]['upline']} ");
            }
            topUplineList.add(teamSalesList[0]['upline']);
            topUplineList.add(teamSalesList[1]['upline']);
            topUplineList.add(teamSalesList[2]['upline']);
          }

          teamSalesList.removeWhere((element) {
            if (kDebugMode) {
              print("profile upline: ${profile.upline} ");
            }
            return element['upline'] != profile.upline;
          });
          bool isEqual = true;
          if (teamSalesList.isNotEmpty) {
            for (String upline in topUplineList) {
              if (teamSalesList[0]['upline'] == upline) {
                isEqual = true;
                break;
              } else {
                isEqual = false;
              }
            }
            if (!isEqual) {
              teamSalesList.clear();
            }
          }
        }
        debugPrint("TeamSale: ${jsonDecode(response.body)}");
        await compareUplineId();
        if (mounted) {
          setState(() {});
        }
      } else {
        debugPrint("getTeamSales: else Error");
      }
    } catch (e) {
      debugPrint("getTeamSales: ${e.toString()}");
    }
    setLoading(false);
  }

  Future<void> compareUplineId() async {
    String? token = await UserProfileManager().getUserToken();
    try {
      final response = await http.get(
          Uri.parse("${URLs.baseURL}${URLs.referralURL}"),
          headers: {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        debugPrint("compareUplineId: ${jsonDecode(response.body)}");

        upline = jsonDecode(response.body)['data'];
        setState(() {});
        print(upline.where((element) =>
            element['upline'].toString() == profile.id.toString()));
        for (var i = 0; i < upline.length; i++) {
          if (profile.id.toString() == upline[i]['upline'].toString()) {
            names.add(upline[i]['name']);
          }
        }
        print(names);
      } else {
        debugPrint("compareUplineId(): error");
      }
    } catch (e) {
      debugPrint("compareUplineId(): $e");
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        setState(() {
          _currentIndex++;
          if (_currentIndex >= itemCount) {
            _currentIndex = 0;
          }
          _scrollToIndex(_currentIndex);
        });
      }
    });
  }

  void _scrollToIndex(int index) {
    _scrollController.animateTo(
      index * itemExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.linear,
    );
  }

  double get itemExtent => 60.0;
  int get itemCount => teamSalesList.length;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/video.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
        _controller.play();
      });
    getTeamSales().then((value) {
      if (teamSalesList.isNotEmpty) {
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: _isVideoInitialized
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 9 / 16,
                          child: VideoPlayer(_controller),
                        ),
                        const MyProgressBar(),
                        const Positioned(
                          top: 450,
                          left: 110,
                          child: Text(
                            "Team Members",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.optima,
                                color: AppColors.primaryColor),
                          ),
                        ),
                        !salesLoading
                            ? teamSalesList.isNotEmpty
                                ? Positioned(
                                    top: 500,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: 200,
                                      child: TeamList(
                                        data: teamSalesList.isNotEmpty
                                            ? names
                                            : [],
                                        scrollController: _scrollController,
                                      ),
                                    ),
                                  )
                                : const Positioned(
                                    left: 75,
                                    top: 500,
                                    child: Text(
                                        "You are not eligible to enjoy incentive!"),
                                  )
                            : const Positioned(
                                top: 500,
                                left: 110,
                                child: Text("Loading Team please wait..."),
                              ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

// class MyProgressBar extends StatefulWidget {
//   const MyProgressBar({super.key});
//
//   @override
//   State<MyProgressBar> createState() => _MyProgressBarState();
// }
//
// class _MyProgressBarState extends State<MyProgressBar> {
//   int currentLevel = 0;
//   List<bool> levelReached = [false, false, false];
//   HomeModel? _homeModel;
//   bool loadingHome = false;
//   void setLoading(bool status) {
//     setState(() {
//       loadingHome = status;
//     });
//   }
//
//   Future<void> loadHome() async {
//     setLoading(true);
//     String? token = await UserProfileManager().getUserToken();
//     try {
//       final response = await http.get(
//           Uri.parse("${URLs.baseURL}${URLs.getHomeURL}"),
//           headers: {"Authorization": "Bearer $token"});
//
//       if (response.statusCode == 200 &&
//           jsonDecode(response.body)['success'] == true) {
//         debugPrint("home loaded: ${jsonDecode(response.body)}");
//         _homeModel = HomeModel.fromJson(jsonDecode(response.body)['data']);
//       } else {
//         debugPrint("loadHome(): error");
//       }
//     } catch (e) {
//       debugPrint("loadHome(): $e");
//     }
//     setLoading(false);
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     loadHome();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_homeModel != null && _homeModel!.teamSales != null) {
//       levelReached[0] = _homeModel!.teamSales! >= 45000 ? true : false;
//       levelReached[1] = _homeModel!.teamSales! >= 65000 ? true : false;
//       levelReached[2] = _homeModel!.teamSales! >= 100000 ? true : false;
//     }
//
//     return Padding(
//       padding: EdgeInsets.only(
//           right: 15, left: 15, top: MediaQuery.of(context).size.height * 0.05),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // LinearProgressIndicator(
//           //   minHeight: 20,
//           //   value: !loadingHome ? (_homeModel!.teamSales)! / 100000 : null,
//           //   valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
//           //   backgroundColor:  AppColors.threeLevelColor,
//           // ),
//           Padding(
//             padding: const EdgeInsets.only(
//               right: 15,
//               left: 15,
//             ),
//             child: !loadingHome
//                 ? StepProgressIndicator(
//                     totalSteps: 100,
//                     currentStep: !loadingHome
//                         ? int.parse((((_homeModel!.teamSales)! / 100000) * 100)
//                             .round()
//                             .toString())
//                         : 0,
//                     size: 15,
//                     padding: 0,
//                     selectedColor: Colors.yellow,
//                     unselectedColor: Colors.cyan,
//                     roundedEdges: const Radius.circular(10),
//                     selectedGradientColor: const LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [AppColors.topLevelColor, Colors.deepOrange],
//                     ),
//                     unselectedGradientColor: const LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [AppColors.theme, AppColors.primaryColor],
//                     ),
//                   )
//                 : const LinearProgressIndicator(
//                     minHeight: 15,
//                     color: AppColors.topLevelColor,
//                     backgroundColor: AppColors.backgroundColor),
//           ),
//           Row(
//             children: [
//               Padding(
//                 padding: EdgeInsets.only(
//                     left: MediaQuery.of(context).size.width * 0.4),
//                 child: LevelCircle(level: 1, reached: levelReached[0]),
//               ),
//               Padding(
//                 padding: EdgeInsets.only(
//                     left: MediaQuery.of(context).size.width * 0.1),
//                 child: LevelCircle(level: 2, reached: levelReached[1]),
//               ),
//               Padding(
//                 padding: EdgeInsets.only(
//                     left: MediaQuery.of(context).size.width * 0.16),
//                 child: LevelCircle(level: 3, reached: levelReached[2]),
//               ),
//             ],
//           ),
//           Positioned(
//               left: 30,
//               child: Text(
//                 _homeModel != null ? _homeModel!.teamSales.toString() : "",
//                 style: const TextStyle(
//                     color: AppColors.backgroundColor,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: AppFonts.arial),
//               )),
//         ],
//       ),
//     );
//   }
// }

class MyProgressBar extends StatefulWidget {
  const MyProgressBar({super.key});

  @override
  State<MyProgressBar> createState() => _MyProgressBarState();
}

class _MyProgressBarState extends State<MyProgressBar> {
  int currentLevel = 0;
  List<bool> levelReached = [false, false, false];
  HomeModel? _homeModel;
  bool loadingHome = false;
  Color borderColor = AppColors.primaryColor;
  Timer? _timer = Timer(const Duration(milliseconds: 500), () {});

  void setLoading(bool status) {
    if (mounted) {
      setState(() {
        loadingHome = status;
      });
    }
  }

  Future<void> loadHome() async {
    setLoading(true);
    String? token = await UserProfileManager().getUserToken();
    try {
      final response = await http.get(
          Uri.parse("${URLs.baseURL}${URLs.getHomeURL}"),
          headers: {"Authorization": "Bearer $token"});

      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        debugPrint("home loaded: ${jsonDecode(response.body)}");
        _homeModel = HomeModel.fromJson(jsonDecode(response.body)['data']);
      } else {
        debugPrint("loadHome(): error");
      }
    } catch (e) {
      debugPrint("loadHome(): $e");
    }
    setLoading(false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        setState(() {
          borderColor = borderColor == Colors.white54
              ? AppColors.primaryColor
              : Colors.white54;
        });
      }
    });
    loadHome();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_homeModel != null && _homeModel!.teamSales != null) {
      levelReached[0] = _homeModel!.teamSales! >= 45000 ? true : false;
      levelReached[1] = _homeModel!.teamSales! >= 65000 ? true : false;
      levelReached[2] = _homeModel!.teamSales! >= 100000 ? true : false;
    }

    return Padding(
      padding: EdgeInsets.only(
          right: 15, left: 15, top: MediaQuery.of(context).size.height * 0.05),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: AnimatedContainer(
              height: 120,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.topLevelColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius:
                      const BorderRadiusDirectional.all(Radius.circular(100)),
                  border: Border.all(width: 4, color: borderColor)),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOutCirc,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color.fromRGBO(255, 255, 255, 0.1),
                    ),
                    child: StepProgressIndicator(
                      totalSteps: 100,
                      currentStep: !loadingHome
                          ? int.parse((((_homeModel!.teamSales)! / 100000) *
                                          100)
                                      .round()
                                      .toString()) >=
                                  100
                              ? 100
                              : int.parse(
                                  (((_homeModel!.teamSales)! / 100000) * 100)
                                      .round()
                                      .toString())
                          : 0,
                      size: 15,
                      padding: 0,
                      selectedColor: AppColors.primaryColor,
                      unselectedColor: AppColors.backgroundColor,
                      roundedEdges: const Radius.circular(10),
                      selectedGradientColor: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.accent, AppColors.accent],
                      ),
                      unselectedGradientColor: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.backgroundColor,
                          AppColors.backgroundColor
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.4),
                child: LevelCircle(level: 1, reached: levelReached[0]),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.1),
                child: LevelCircle(level: 2, reached: levelReached[1]),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.11),
                child: LevelCircle(level: 3, reached: levelReached[2]),
              ),
            ],
          ),
          Positioned(
              bottom: 10,
              child: Text(
                "Your Sales: ${_homeModel != null ? _homeModel!.teamSales.toString() : ""} RM",
                style: const TextStyle(
                    color: AppColors.backgroundColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.arial),
              )),
        ],
      ),
    );
  }
}

class LevelCircle extends StatefulWidget {
  final int level;
  final bool reached;

  const LevelCircle({Key? key, required this.level, required this.reached})
      : super(key: key);

  @override
  _LevelCircleState createState() => _LevelCircleState();
}

class _LevelCircleState extends State<LevelCircle> {
  Color shadowColor = AppColors.primaryColor;
  Timer? _timer = Timer(const Duration(milliseconds: 500), () {});

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        setState(() {
          shadowColor = shadowColor == Colors.white54
              ? AppColors.primaryColor
              : Colors.white54;
        });
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _timer!.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: 30,
      child: widget.reached ? _buildGlowingCircle() : _buildNormalCircle(),
    );
  }

  Widget _buildNormalCircle() {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: AppColors.threeLevelColor,
        ),
        child: Center(
          child: Text(
            widget.level.toString(),
            style: const TextStyle(
              color: AppColors.backgroundColor,
              fontFamily: AppFonts.optima,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlowingCircle() {
    return Card(
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.topLevelColor,
              AppColors.twoLevelColor,
              AppColors.theme,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor, // Use the generated shadow color
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.done_rounded,
            color: AppColors.backgroundColor,
            size: 15,
          ),
        ),
      ),
    );
  }
}
