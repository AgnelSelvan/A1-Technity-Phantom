class User {
  String uid;
  String name;
  String email;
  String username;
  String profilePhoto;
  String deviceToken;
  String role;
  String address;
  String state;
  String gstin;
  int pincode;
  String mobileNo;

  User(
      {this.uid,
      this.name,
      this.email,
      this.username,
      this.state,
      this.profilePhoto,
      this.deviceToken,
      this.role,
      this.address,
      this.gstin,
      this.pincode,
      this.mobileNo});

  Map toMap(User user) {
    var data = Map<String, dynamic>();
    data['uid'] = user.uid;
    data['name'] = user.name;
    data['email'] = user.email;
    data['username'] = user.username;
    data["state"] = user.state;
    data["profile_photo"] = user.profilePhoto;
    data["device_token"] = user.deviceToken;
    data['role'] = user.role;
    data['address'] = user.address;
    data['gstin'] = user.gstin;
    data['pincode'] = user.pincode;
    data['mobile_no'] = user.mobileNo;
    return data;
  }

  // Named constructor
  User.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['uid'];
    this.name = mapData['name'];
    this.email = mapData['email'];
    this.username = mapData['username'];
    this.state = mapData['state'];
    this.profilePhoto = mapData['profile_photo'];
    this.deviceToken = mapData['device_token'];
    this.role = mapData['role'];
    this.address = mapData['address'];
    this.gstin = mapData['gstin'];
    this.pincode = mapData['pincode'];
    this.mobileNo = mapData['mobile_no'];
  }
}
