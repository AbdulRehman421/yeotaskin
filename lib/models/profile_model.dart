
class ProfileModel {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? profilePhoto;
  String? gender;
  String? dob;
  String? icNumber;
  String? level;
  String? upline;
  String? userName;
  String? role;
  String? upLineName;
  String? memo;
  String? attachment;
  String? userType;
  String? status;
  String? createdAt;
  String? profileUrl;
  String? moq;

  ProfileModel(
      {this.id,
        this.name,
        this.email,
        this.phone,
        this.profilePhoto,
        this.gender,
        this.dob,
        this.icNumber,
        this.level,
        this.upline,
        this.userName,
        this.role,
        this.upLineName,
        this.memo,
        this.attachment,
        this.userType,
        this.status,
        this.createdAt,
        this.profileUrl,
      this.moq});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'].toString();
    email = json['email'].toString();
    phone = json['phone'].toString();
    profilePhoto = json['profile_photo'].toString();
    gender = json['gender'].toString();
    dob = json['dob'].toString();
    icNumber = json['ic_number'].toString();
    level = json['level'].toString();
    upline = json['upline'].toString();
    userName = json['user_name'].toString();
    role = json['role'].toString();
    upLineName = json['up_line_name'].toString();
    memo = json['memo'].toString();
    attachment = json['attachment'].toString();
    userType = json['user_type'].toString();
    status = json['status'].toString();
    createdAt = json['created_at'].toString();
    profileUrl = json['profile_url'].toString();
    moq = json['moq'].toString();
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data['id'] = id;
  //   data['name'] = name;
  //   data['email'] = email;
  //   data['phone'] = phone;
  //   data['profile_photo'] = profilePhoto;
  //   data['gender'] = gender;
  //   data['dob'] = dob;
  //   data['ic_number'] = icNumber;
  //   data['level'] = level;
  //   data['upline'] = upline;
  //   data['user_name'] = userName;
  //   data['role'] = role;
  //   data['up_line_name'] = upLineName;
  //   data['memo'] = memo;
  //   data['attachment'] = attachment;
  //   data['user_type'] = userType;
  //   data['status'] = status;
  //   data['created_at'] = createdAt;
  //   data['profile_url'] = profileUrl;
  //   return data;
  // }
}