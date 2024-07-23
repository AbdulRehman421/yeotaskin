import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../APIs/app_constant.dart';
import '../APIs/urls.dart';
import '../models/profile_model.dart';

class UserProfileManager {
  static final UserProfileManager _instance = UserProfileManager._internal();
  late ProfileModel profile;

  factory UserProfileManager() {
    return _instance;
  }

  UserProfileManager._internal();
  Future<void> loadProfile() async {
    String? token = await getUserToken();
    try {
      final response = await http.get(
        Uri.parse("${URLs.baseURL}${URLs.getUserProfileURL}"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
if (kDebugMode) {
  print(token);
}
      if (response.statusCode == 200 && jsonDecode(response.body)['success'] == true) {
        debugPrint("Profile Done : ${jsonDecode(response.body)}");

        Map<String, dynamic> data = jsonDecode(response.body)['data'];
        profile = ProfileModel.fromJson(data);
      } else {
        debugPrint("loadProfile(): error");
        debugPrint("loadProfile(): ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<String?> getUserToken() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstant.accessToken);
  }
}
