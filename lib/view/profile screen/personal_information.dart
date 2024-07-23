import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yeotaskin/main.dart';
import 'package:yeotaskin/models/profile_model.dart';
import 'package:yeotaskin/services/user_profile_manager.dart';
import 'package:http/http.dart' as http;
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/utilities/snackbar_utils.dart';
import 'package:yeotaskin/view/profile%20screen/pdf_view_screen.dart';
import '../../APIs/app_constant.dart';
import '../../APIs/urls.dart';
import '../../utilities/app_colors.dart';
import '../auth/register-screen.dart';

class PersonalInformation extends StatefulWidget {
  final Function updatePhoto;
  const PersonalInformation({super.key, required this.updatePhoto});

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  ProfileModel profile = UserProfileManager().profile;
  void navigateRegisterScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove(AppConstant.accessToken);
    navigateRegisterScreen();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        surfaceTintColor: AppColors.backgroundColor,
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          "Profile Information",
          style: TextStyle(
            fontFamily: AppFonts.palatino,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        title: const Text(
                          "Logout Account",
                          style: TextStyle(
                            fontFamily: AppFonts.palatino,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                        content: const Text(
                          "Do you want to logout?",
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: AppFonts.optima,
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.backgroundColor,
                                foregroundColor: AppColors.accent,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.palatino,
                                ),
                              )),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: AppColors.backgroundColor),
                            onPressed: () {
                              logOut();
                            },
                            child: const Text(
                              "Confirm",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.palatino,
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  );
                },
                child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Center(child: Icon(Icons.logout)))),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  height: mq.height * 0.05,
                ),
                Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                        child: Center(
                          child: CircleAvatar(
                            maxRadius: 80,
                            backgroundColor: AppColors.backgroundColor,
                            foregroundImage: profile.profilePhoto!.isNotEmpty
                                ? NetworkImage(profile.profilePhoto!)
                                : null,
                            child: const Icon(
                              Icons.person,
                              size: 100,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.12,
                          left: MediaQuery.of(context).size.height * 0.15,
                        ),
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryColor),
                            child: Center(
                                child: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              onTap: () {
                                changeProfilePhoto();
                              },
                              child: const Icon(
                                Icons.add_a_photo,
                                color: AppColors.backgroundColor,
                                size: 25,
                              ),
                            ))),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: mq.height * 0.02,
                ),
                rowProfile("Name", profile.name ?? ""),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                const Divider(color: Colors.black12),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                rowProfile("User Name", profile.userName!),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                const Divider(color: Colors.black12),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                rowProfile("Email", profile.email!),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                const Divider(color: Colors.black12),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                rowProfile("Phone", profile.phone!),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                const Divider(color: Colors.black12),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                rowProfile("DOB", profile.dob!),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                const Divider(color: Colors.black12),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                rowProfile("Gender", profile.gender!),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                const Divider(color: Colors.black12),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                rowProfile("IC Number", profile.icNumber!),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                const Divider(color: Colors.black12),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                rowProfile("Level", profile.level!),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                const Divider(color: Colors.black12),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                rowProfile("Role", profile.role!),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                const Divider(color: Colors.black12),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                rowProfile("Upline Name", profile.upLineName!),
                SizedBox(
                  height: mq.height * 0.01,
                ),
                SizedBox(
                  height: mq.height * 0.02,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              surfaceTintColor: Colors.transparent,
                              title: const Text(
                                "Delete Account",
                                style: TextStyle(
                                  fontFamily: AppFonts.palatino,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                              content: const Text(
                                "Do you want to delete your account permanently?",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: AppFonts.optima,
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.backgroundColor,
                                      foregroundColor: AppColors.accent,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppFonts.palatino,
                                      ),
                                    )),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor:
                                          AppColors.backgroundColor),
                                  onPressed: () {
                                    deleteAccount();
                                  },
                                  child: const Text(
                                    "Confirm",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppFonts.palatino,
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        );
                      },
                      child: !deleteLoading
                          ? const Text(
                              "Delete Account",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: AppFonts.optima,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const CircularProgressIndicator(
                              color: Colors.white,
                            )),
                ),
                SizedBox(
                  height: mq.height * 0.03,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool deleteLoading = false;
  void setLoading(bool status) {
    setState(() {
      deleteLoading = status;
    });
  }

  void navigateToRegisterScreen() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
        ));
  }

  Future<void> deleteAccount() async {
    setLoading(true);
    String? token = await UserProfileManager().getUserToken();
    try {
      final response = await http
          .post(Uri.parse("${URLs.baseURL}${URLs.deleteAccountURL}"), headers: {
        "Authorization": "Bearer $token",
      }, body: {
        "user_id": profile.id.toString(),
      });

      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        if (!mounted) {
          return;
        }
        debugPrint("account deleted : ${response.body}");
        logOut();
      } else {
        debugPrint("deleteAccount(): else Error");
      }
    } catch (e) {
      debugPrint("deleteAccount(): $e");
    }
    setLoading(false);
  }

  Row rowProfile(String name, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          name,
          style: const TextStyle(
              fontFamily: AppFonts.palatino,
              fontSize: 16,
              fontWeight: FontWeight.normal),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppFonts.optima,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> changeProfilePhoto() async {
    Map<Permission, PermissionStatus> status = await [
      Permission.storage,
    ].request();

    if (status[Permission.storage]!.isGranted) {
      debugPrint("Storage Permission Granted");
      try {
        final ImagePicker _picker = ImagePicker();
        XFile? pickedImage = await _picker.pickImage(
          source: ImageSource.gallery,
          maxHeight: 512,
          maxWidth: 512,
          imageQuality: 72,
        );
        if (pickedImage == null) {
          return;
        }
        CroppedFile? croppedImage = await ImageCropper().cropImage(
            sourcePath: pickedImage!.path,
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
          updateProfilePhoto(croppedFile);
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

  Future<void> updateProfilePhoto(File photo) async {
    String? token = await UserProfileManager().getUserToken();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("${URLs.baseURL}${URLs.updateUserProfileURL}"),
      );

      request.headers['Authorization'] = "Bearer $token";
      request.fields["name"] = profile.name ?? "";
      request.fields["email"] = profile.email ?? "";
      request.fields["phone"] = profile.phone ?? "";

      request.files.add(
        await http.MultipartFile.fromPath(
          "profile_photo",
          photo.path,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        if (jsonDecode(responseBody)['success'] == true) {
          loadProfile();
          widget.updatePhoto();
          debugPrint("updateProfilePhoto: updated");
          SnackBarUtils.show(
              title: 'Profile Photo updated', isError: false, duration: 2);
        } else {
          debugPrint("updateProfilePhoto: error occurred");
          SnackBarUtils.show(
              title: "An error occurred", isError: true, duration: 2);
        }
      } else {
        SnackBarUtils.show(
            title: "An error occurred", isError: true, duration: 2);
        debugPrint("updateProfilePhoto: HTTP error occurred");
      }
    } catch (e) {
      SnackBarUtils.show(title: e.toString(), isError: true, duration: 2);
      debugPrint("updateProfilePhoto: $e");
    }
  }

  Future loadProfile() async {
    await UserProfileManager().loadProfile();
    setState(() {
      profile = UserProfileManager().profile;
    });
  }
}
