import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/models/review.dart';

// class User {
//   String uid, username, email, photoUrl;
//   Map<String, dynamic> deliveryAddress;
//   List<DummyProductModel> cartProducts, boughtProducts;
//   List<Review> reviews;
//   String role;
//   User(
//       {this.uid,
//       this.username,
//       this.email,
//       this.photoUrl,
//       this.deliveryAddress,
//       this.cartProducts,
//       this.boughtProducts,
//       this.reviews,
//       this.role});
//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid ?? '',
//       'name': username ?? '',
//       'email': email ?? '',
//       'photoUrl': photoUrl ?? '',
//       'deliveryAddress': deliveryAddress ??
//           {'address': '', 'pincode': '', 'state': '', 'city': ''},
//       'cartProducts': cartProducts ?? [],
//       'boughtProducts': boughtProducts ?? [],
//       'reviews': reviews ?? [],
//       'role': role ?? ''
//     };
//   }

//   factory User.fromMap(Map snapshot) {
//     snapshot = snapshot ?? {};
//     return User(
//         username: snapshot["username"],
//         email: snapshot["email"],
//         deliveryAddress: snapshot["deliveryAddress"],
//         cartProducts: snapshot["cartProducts"],
//         boughtProducts: snapshot["boughtProducts"],
//         reviews: snapshot["reviews"]);
//   }

//   factory User.fromFirestore(DocumentSnapshot doc) {
//     Map data = doc.data();
//     return User(
//         username: data["username"] ?? '',
//         email: data["email"] ?? '',
//         deliveryAddress: data["deliveryAddress"] ?? '',
//         cartProducts: data["cartProducts"] ?? [],
//         boughtProducts: data["boughtProducts"] ?? [],
//         reviews: data["reviews"] ?? 0);
//   }
// }

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
