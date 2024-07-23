import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/view/incentive/show_video_screen.dart';
import '../../models/home_model.dart';
import '../../utilities/app_colors.dart';

class IncentiveScreen extends StatefulWidget {
  const IncentiveScreen({super.key});

  @override
  State<IncentiveScreen> createState() => _IncentiveScreenState();
}

class _IncentiveScreenState extends State<IncentiveScreen> {

  HomeModel? _homeModel;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
      body: _homeModel!.teamSales! <= 400000 ? Container() :  VideoScreen(),
    );
  }
}
