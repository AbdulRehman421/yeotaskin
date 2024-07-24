import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/view/incentive/show_video_screen.dart';
import '../../APIs/urls.dart';
import '../../models/home_model.dart';
import '../../services/user_profile_manager.dart';
import '../../utilities/app_colors.dart';

class IncentiveScreen extends StatefulWidget {
  const IncentiveScreen({super.key});

  @override
  State<IncentiveScreen> createState() => _IncentiveScreenState();
}

class _IncentiveScreenState extends State<IncentiveScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadHome();
  }
  void setLoading(bool status) {
    if (mounted) {
      setState(() {
        loadingHome = status;
      });
    }
  }

  HomeModel? _homeModel;
  bool loadingHome = false;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          "Yeotaskin Incentive",
          style: TextStyle(
            fontFamily: AppFonts.palatino,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: VideoScreen(),
    );
  }
}
