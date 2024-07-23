import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yeotaskin/view/profile%20screen/knowledge%20base/view_pdf.dart';
import 'package:yeotaskin/view/profile%20screen/knowledge%20base/view_video.dart';

import '../../../APIs/urls.dart';
import '../../../services/user_profile_manager.dart';
import '../../../utilities/app_colors.dart';
import '../../../utilities/app_fonts.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  bool loadingKnowledgeBase = false;
  List knowledgeBase = [];
  void setLoading(bool status) {
    setState(() {
      loadingKnowledgeBase = status;
    });
  }

  Future<void> getKnowledgeBase() async {
    String? token = await UserProfileManager().getUserToken();
    try {
      final response = await http.get(
        Uri.parse("${URLs.baseURL}${URLs.getKnowledgeBaseURL}"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      if (kDebugMode) {
        print(response.statusCode);
      }
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (kDebugMode) {
          print(data);
        }
        if (data.isNotEmpty) {
          knowledgeBase = data['data'];
        }
        setState(() {});
      } else {
        debugPrint("getKnowledgeBase(): error");
      }
    } catch (e) {
      debugPrint("getKnowledgeBase: $e");
    }
    setLoading(false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getKnowledgeBase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        surfaceTintColor: AppColors.backgroundColor,
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'Knowledge Base',
          style: TextStyle(
            fontFamily: AppFonts.palatino,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: knowledgeBase.length,
        itemBuilder: (context, index) {
          List videoNameList = knowledgeBase[index]['k_video'].split("/");
          String videoName = videoNameList.elementAt(videoNameList.length-1);

          List fileNameList = knowledgeBase[index]['k_file'].split("/");
          String fileName = fileNameList.elementAt(fileNameList.length-1);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewVideoScreen(
                              videoUrl: knowledgeBase[index]
                              ['k_video']),
                        ));
                  },
                  child: Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(videoName,style:TextStyle(fontFamily: AppFonts.optima,fontSize: 16)),
                        ),
                        IconButton(
                            onPressed: () {

                            },
                            icon: const Icon(
                              Icons.videocam_sharp,
                              color: AppColors.primaryColor,
                            )),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(fileName,style:TextStyle(fontFamily: AppFonts.optima,fontSize: 16)),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewPdfScreen(
                                      url: knowledgeBase[index]['k_file']),
                                ));
                          },
                          icon: const Icon(
                            Icons.file_open,
                            color: AppColors.primaryColor,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
