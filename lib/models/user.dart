class UserModel {
  String uid;
  String name;
  String email;
  String username;
  String profilePhoto;
  String role;
  String mobileNo;

  UserModel(
      {this.uid,
      this.name,
      this.email,
      this.username,
      this.profilePhoto,
      this.role,
      this.mobileNo});

  Map toMap(UserModel user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['name'] = user.name;
    data['email'] = user.email;
    data['username'] = user.username;
    data["profile_photo"] = user.profilePhoto;
    data['role'] = user.role;
    data['mobile_no'] = user.mobileNo;
    return data;
  }

  // Named constructor
  UserModel.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['name'];
    this.email = mapData['email'];
    this.username = mapData['username'];
    this.profilePhoto = mapData['profile_photo'];
    this.role = mapData['role'];
    this.mobileNo = mapData['mobile_no'];
  }
}
