import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/view/dashboard/dash_board.dart';
import 'package:yeotaskin/view/dashboard/widgets/gradient_icon.dart';
import 'package:yeotaskin/view/incentive/incentive_screen.dart';
import 'package:yeotaskin/view/leader%20board/leader_board.dart';
import 'package:yeotaskin/view/product%20screen/product_screen.dart';
import 'package:yeotaskin/view/profile%20screen/profile_screen.dart';

import '../models/profile_model.dart';
import '../services/user_profile_manager.dart';
import '../utilities/app_colors.dart';
import 'dashboard/todo/TodoScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;

  int _currentIndex = 0;
  final List<Widget> _pages = [
    const DashBoard(),
    const ProductScreen(),
    const LeaderBoardScreen(),
    const IncentiveScreen(),
    const TodoScreen(),
    const ProfileScreen(),
  ];

  bool profileLoading = false;
  ProfileModel? profile;
  Future loadProfile() async {
    setLoading(true);
    await UserProfileManager().loadProfile().then((value) {
      setState(() {
        profile = UserProfileManager().profile;
      });
    });
    setLoading(false);
  }

  void setLoading(bool status) {
    setState(() {
      profileLoading = status;
    });
  }

  @override
  void initState() {
    loadProfile();
    _pageController = PageController(initialPage: _currentIndex);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !profileLoading
        ? profile != null
            ? WillPopScope(
                onWillPop: () {
                  SystemNavigator.pop();
                  return Future(() => true);
                },
                child: Scaffold(
                  backgroundColor: AppColors.backgroundColor,
                  body: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _pages,
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    elevation: 10,
                    type: BottomNavigationBarType.fixed,
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                        _pageController.jumpToPage(index);
                      });
                    },
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        activeIcon: GradientIcon(
                          Icons.home,
                          24,
                          LinearGradient(
                            colors: [
                              Color(0xffcc998d),
                              Color(0xff554348),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_basket_outlined),
                        activeIcon: GradientIcon(
                          Icons.shopping_basket,
                          24,
                          LinearGradient(
                            colors: [
                              Color(0xffcc998d),
                              Color(0xff554348),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        label: 'Products',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.stacked_bar_chart_outlined),
                        activeIcon: GradientIcon(
                          Icons.stacked_bar_chart,
                          24,
                          LinearGradient(
                            colors: [
                              Color(0xffcc998d),
                              Color(0xff554348),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        label: 'Leaderboard',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_bag_outlined),
                        activeIcon: GradientIcon(
                          Icons.shopping_bag_rounded,
                          24,
                          LinearGradient(
                            colors: [
                              Color(0xffcc998d),
                              Color(0xff554348),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        label: 'Incentive',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.today_outlined),
                        activeIcon: GradientIcon(
                          Icons.today_rounded,
                          24,
                          LinearGradient(
                            colors: [
                              Color(0xffcc998d),
                              Color(0xff554348),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        label: 'Todo',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        activeIcon: GradientIcon(
                          Icons.person,
                          24,
                          LinearGradient(
                            colors: [
                              Color(0xffcc998d),
                              Color(0xff554348),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        label: 'Profile',
                      ),
                    ],
                    backgroundColor: Colors.white,
                    showUnselectedLabels: false,
                    selectedItemColor: AppColors.topLevelColor,
                    selectedLabelStyle: const TextStyle(
                      fontFamily: AppFonts.arial,
                    ),
                    unselectedItemColor:
                        AppColors.primaryColor.withOpacity(0.5),
                  ),
                ),
              )
            : WillPopScope(
                onWillPop: () {
                  SystemNavigator.pop();

                  return Future(() => true);
                },
                child: Scaffold(
                  backgroundColor: AppColors.backgroundColor,
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                        child: Text("Something went wrong!"),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        style: const ButtonStyle(
                            overlayColor: MaterialStatePropertyAll(
                                AppColors.primaryColor)),
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ));
                        },
                        child: const Text(
                          "Retry",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      )
                    ],
                  ),
                ),
              )
        : WillPopScope(
            onWillPop: () {
              SystemNavigator.pop();
              return Future(() => true);
            },
            child: Container(
              color: AppColors.backgroundColor,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            ),
          );
  }
}
