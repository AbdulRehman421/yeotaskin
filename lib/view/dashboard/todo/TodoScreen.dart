import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yeotaskin/utilities/snackbar_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yeotaskin/view/dashboard/widgets/gradient_icon.dart';

import '../../../APIs/urls.dart';
import '../../../models/profile_model.dart';
import '../../../services/user_profile_manager.dart';
import '../../../utilities/app_colors.dart';
import '../../../utilities/app_fonts.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with TickerProviderStateMixin {
  List taskList = [];
  List prizesList = [];
  bool taskLoading = false;

  void setLoading(bool status) {
    setState(() {
      taskLoading = status;
    });
  }

  Future<void> getPrizes() async {

    try {
      final response =
      await http.get(Uri.parse("${URLs.baseURL}${URLs.getPrizesURL}"));
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        if (jsonDecode(response.body)['prizes'] != null) {
          prizesList = jsonDecode(response.body)['prizes'];
          prizesList.removeWhere((element) => element['POINT'] != taskList[0]['user']['income']);
          debugPrint("Prize List: ${prizesList.toString()}");
        }
        setState(() {});
      } else {
        debugPrint("getPrizes: else Error");
      }
    } catch (e) {
      debugPrint("getPrizes: ${e.toString()}");
    }
    setLoading(false);
  }
  Future<void> getTasks() async {
    setLoading(true);
    ProfileModel profile = UserProfileManager().profile;
    try {
      final response =
          await http.get(Uri.parse("${URLs.baseURL}${URLs.getTaskURL}"));

      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        if (jsonDecode(response.body)['tasks'] != null) {
          taskList = jsonDecode(response.body)['tasks'];
          taskList.removeWhere((element) => int.parse(element['assigned_to'] ?? "-1") != profile.id);
          debugPrint("Task List: ${taskList.toString()}");
          if(taskList.isNotEmpty){
            if( double.parse( (taskList[0]['user']['income'] ?? 0).toString()) > 0.0 ){
              getPrizes();
            }
          }

        }
        setState(() {});
      } else {
        debugPrint("getTasks: else Error");
      }
    } catch (e) {
      debugPrint("getTasks: ${e.toString()}");
    }
    setLoading(false);
  }

  Future<void> submitTasks(Map<String, dynamic> task, File file) async {
    String fileName = file.path.split('/').last;
    EasyLoading.show(status: "Submitting Task...",);
    try {
      final request = http.MultipartRequest(
          "POST", Uri.parse("${URLs.baseURL}${URLs.postTaskURL}"));
      request.fields['assigned_to'] = task['assigned_to'];
      request.fields['task_name'] = task["task_name"];
      request.fields['task_description'] = task["task_description"];
      request.fields['point'] = task["point"];

      request.files.add(http.MultipartFile(
          'attachment', file.readAsBytes().asStream(), file.lengthSync(),
          filename: fileName));

      // request.files.add(http.MultipartFile(
      //     'attachment_doc', file.readAsBytes().asStream(), file.lengthSync(),
      //     filename: "${DateTime.now().millisecondsSinceEpoch}.pdf"));

      final response = await request.send();
      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        if (jsonDecode(responseBody)['success'] == true) {
          debugPrint("Task Submitted: ${responseBody.toString()}");
          SnackBarUtils.show(
              title: "Task Submitted Successfully!", isError: false);
        } else {
          SnackBarUtils.show(
              title: "Task Not Submitted!",
              isError: true);
        }
      } else {
        SnackBarUtils.show(
            title: "Something went wrong while submitting task (max_file_size is 600KB",
            isError: true);
        debugPrint("getTasks: else Error");
      }
    } catch (e) {
      debugPrint("getTasks: ${e.toString()}");
    }
    EasyLoading.dismiss();
  }

  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(vsync: this,duration: const Duration(seconds: 2) );
    _animation = Tween<double>(begin: 1.0,end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
    _controller.repeat(reverse: true,);
    getTasks();



  }
 @override
  void dispose() {
    // TODO: implement dispose
   _controller.dispose();
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        automaticallyImplyLeading: false,
        surfaceTintColor: AppColors.backgroundColor,
        title: const Text(
          "Todo",
          style: TextStyle(
            fontFamily: AppFonts.palatino,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(!taskLoading)
                Card(
                  elevation: 5,
                  margin: const EdgeInsets.only(top: 10),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1,
                    height: MediaQuery.of(context).size.height * 0.22,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 1,
                          child: toDoPointsWidget("Individual Point", taskList.isNotEmpty ?  taskList[0]['user']['income'] ?? "" : "0" ),
                        ),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          indent: 50,
                          endIndent: 50,
                          color: Colors.white.withOpacity(0.25),
                        ),
                        Flexible(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              prizesList.isNotEmpty ?
                              ScaleTransition(
                                scale: _animation,
                                child: const GradientIcon(Icons.card_giftcard, 50, LinearGradient(colors: [AppColors.primaryColor,AppColors.topLevelColor])),
                              )
                              :const GradientIcon(Icons.card_giftcard, 50, LinearGradient(colors: [AppColors.primaryColor,AppColors.topLevelColor])),
                              Text(prizesList.isNotEmpty ? "${prizesList[0]['PRIZE']}" : "No Prize for you",
                                style: const TextStyle(fontFamily: AppFonts.optima,fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white),
                              ),
                              Text(prizesList.isNotEmpty ? "${prizesList[0]['POINT']} Points"  : "",
                                style: const TextStyle(fontFamily: AppFonts.optima,fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        // Expanded(
                        //   flex: 1,
                        //   child:
                        // ),
                        // Expanded(
                        //   flex: 1,
                        //   child: toDoPointsWidget(
                        //     'Team Point',
                        //     "100",
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                !taskLoading
                    ? taskList.isNotEmpty
                        ? Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: taskList.length,
                              itemBuilder: (context, index) {
                                return todoCard(
                                  onTap: () {
                                    getAttachment(taskList[index]);
                                  },
                                  todoName: taskList[index]['task_name'],
                                  todoPoints: taskList[index]['point'],
                                  assetImagePath: "assets/images/note.png",
                                  backgroundColors: [
                                    const Color(0xffcc998d),
                                    const Color(0xff554348),
                                  ],
                                );
                              },
                            ),
                          )
                        : const Center(
                            child: Text("No Task Found!"),
                          )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
              ],
            )),
      ),
    );
  }
  void getAttachment(Map<String, dynamic> task) {
    showModalBottomSheet(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      showDragHandle: true,
      shape: const OutlineInputBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          borderSide: BorderSide.none),
      builder: (context) {
        return SizedBox(
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                  onPressed: () {
                    Navigator.pop(context);
                     getImage(ImageSource.camera, task);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.camera_alt,
                      color: AppColors.primaryColor,
                      size: 30,
                    ),
                  )),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                  onPressed: () {
                    Navigator.pop(context);
                    getImage(ImageSource.gallery, task);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.photo,
                      color: AppColors.primaryColor,
                      size: 30,
                    ),
                  )),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                  onPressed: () {
                    Navigator.pop(context);
                    getFile(task);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      color: AppColors.primaryColor,
                      Icons.attach_file,
                      size: 30,
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
  Future getImage(ImageSource source, Map<String, dynamic> task) async {
    Map<Permission, PermissionStatus> status = await [
      Permission.storage,
    ].request();
    if (status[Permission.storage]!.isGranted) {
      debugPrint("Storage Permission Granted");
      try {
        final ImagePicker picker = ImagePicker();
        XFile? pickedImage = await picker.pickImage(
          source: source == ImageSource.gallery ? ImageSource.gallery : ImageSource.camera,
          maxHeight: 512,
          maxWidth: 512,
          imageQuality: 72,
        );
        if (pickedImage == null) {
          return;
        }
        CroppedFile? croppedImage = await ImageCropper().cropImage(
            sourcePath: pickedImage.path,
            maxWidth: 500,
            maxHeight: 500,
            cropStyle: CropStyle.circle,
            aspectRatioPresets: [
              CropAspectRatioPreset.square
            ],
            uiSettings: [
              IOSUiSettings(
                aspectRatioLockEnabled: true,
              ),
              AndroidUiSettings(
                lockAspectRatio: true,
              )
            ]);
        if (croppedImage != null) {
          File croppedFile = File(croppedImage.path);
          submitTasks(task, croppedFile);
        }
      } catch (e) {
        SnackBarUtils.show(title: e.toString(), isError: true, duration: 2);
        debugPrint("changeProfilePhoto() : ${e.toString()}");
      }
    } else {
      SnackBarUtils.show(
          title: 'Storage Permission Not Granted', isError: true, duration: 2);
      debugPrint("Storage Permission Not Granted");
    }
  }

  Future<void> getFile(Map<String, dynamic> task) async {
    try {

      final pickedFile = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: false);
      if (pickedFile != null) {
        submitTasks(task, File(pickedFile.files.single.path!));
      }
    } catch (e) {
      debugPrint("getFile(): $e");
    }
  }

  Widget toDoPointsWidget(
    String title,
    String amount, {
    Color? titleColor,
    Color textColor = Colors.white,
    bool centerTitle = true,
  }) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: titleColor ?? Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.optima,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Text(
                  amount,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: AppFonts.optima,
                  ),
                ),
              ),
              Text(
                'Points',
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontFamily: AppFonts.youngSerifDefault,
                ),
              ),

            ],
          ),
        ],
      );

  Widget todoCard({
    required GestureTapCallback onTap,
    required String todoName,
    required String todoPoints,
    required String assetImagePath,
    required List<Color> backgroundColors,
  }) =>
      Stack(
        children: [
          InkWell(
            onTap: onTap,
            child: Card(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 20),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: backgroundColors,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                      child: toDoPointsWidget(
                        "Task Name: $todoName",
                        "Points: $todoPoints",
                        titleColor: Colors.white,
                        centerTitle: false,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          // Positioned(
          //   right: 30,
          //   top: 0,
          //   child: Image(
          //     image: AssetImage(assetImagePath),
          //     height: 70,
          //   ),
          // )
        ],
      );

}
