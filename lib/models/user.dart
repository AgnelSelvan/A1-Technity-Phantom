import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/models/review.dart';

class User {
  String uid, username, email, photoUrl;
  Map<String, dynamic> deliveryAddress;
  List<Product> cartProducts, boughtProducts;
  List<Review> reviews;
  String role;
  User(
      {this.uid,
      this.username,
      this.email,
      this.photoUrl,
      this.deliveryAddress,
      this.cartProducts,
      this.boughtProducts,
      this.reviews,
      this.role});
  Map<String, dynamic> toMap() {
    return {
      'uid': uid ?? '',
      'name': username ?? '',
      'email': email ?? '',
      'photoUrl': photoUrl ?? '',
      'deliveryAddress': deliveryAddress ??
          {'address': '', 'pincode': '', 'state': '', 'city': ''},
      'cartProducts': cartProducts ?? [],
      'boughtProducts': boughtProducts ?? [],
      'reviews': reviews ?? [],
      'role': role ?? ''
    };
  }

  factory User.fromMap(Map snapshot) {
    snapshot = snapshot ?? {};
    return User(
        username: snapshot["username"],
        email: snapshot["email"],
        deliveryAddress: snapshot["deliveryAddress"],
        cartProducts: snapshot["cartProducts"],
        boughtProducts: snapshot["boughtProducts"],
        reviews: snapshot["reviews"]);
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data();
    return User(
        username: data["username"] ?? '',
        email: data["email"] ?? '',
        deliveryAddress: data["deliveryAddress"] ?? '',
        cartProducts: data["cartProducts"] ?? [],
        boughtProducts: data["boughtProducts"] ?? [],
        reviews: data["reviews"] ?? 0);
  }
}
