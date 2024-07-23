import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yeotaskin/models/profile_model.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:yeotaskin/view/profile%20screen/income%20log%20screen/widget/income_log_card.dart';

import '../../../APIs/urls.dart';
import '../../../services/user_profile_manager.dart';
import '../../../utilities/app_colors.dart';

class IncomeLogScreen extends StatefulWidget {
  const IncomeLogScreen({super.key});

  @override
  State<IncomeLogScreen> createState() => _IncomeLogScreenState();
}

class _IncomeLogScreenState extends State<IncomeLogScreen> {
  bool loadingIncomeLog = false;
  List incomeLogList = [];
  void setLoading(bool status) {
    setState(() {
      loadingIncomeLog = status;
    });
  }

  Future<void> getIncomeLog() async {
    setLoading(true);
    String? token = await UserProfileManager().getUserToken();
    ProfileModel profile = UserProfileManager().profile;
    try {
      final response = await http.get(
          Uri.parse("${URLs.baseURL}${URLs.getIncomeLogs}"),
          headers: {"Authorization": "Bearer $token"});
      if (kDebugMode) {
        print("Income Logs ${response.statusCode}: ${response.body}");
      }
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        if (jsonDecode(response.body)['data'] != null) {
          if(kDebugMode){
            print("Income Logs : ${jsonDecode(response.body)}");
          }
          incomeLogList = jsonDecode(response.body)['data'];
          incomeLogList.removeWhere((element) => element['agent'] != profile.id.toString());
        }
        debugPrint("Income logs fetched");
        setState(() {});
      } else {
        debugPrint("getIncomeLog: error");
      }
    } catch (e) {
      debugPrint("getIncomeLog: $e");
    }
    setLoading(false);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getIncomeLog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 1,
        surfaceTintColor: AppColors.backgroundColor,
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          "Income Logs",
          style: TextStyle(
            fontFamily: AppFonts.palatino,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: !loadingIncomeLog
          ? incomeLogList.isNotEmpty
          ? ListView.builder(
        itemCount: incomeLogList.length,
        itemBuilder: (context, index) {
            return IncomeLogCard(description: incomeLogList[index]['description'] ?? "", income: incomeLogList[index]['income'] ?? "", dateTime: incomeLogList[index]['date'] ?? "",);
          },)
          :  const Center(
        child: Text("Income log not found!"),
      )
          : const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
