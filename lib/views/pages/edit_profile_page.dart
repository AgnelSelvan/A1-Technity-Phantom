import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stock_q/views/services/auth.dart';
import 'package:stock_q/views/services/datastore.dart';
import 'package:stock_q/views/styles/custom.dart';
import 'package:stock_q/views/widgets/SectionTitle.dart';
import 'package:stock_q/views/widgets/appbar.dart';
import 'package:stock_q/views/widgets/in_section_spacing.dart';
import 'package:stock_q/views/widgets/link_button.dart';
import 'package:stock_q/views/widgets/primary_button.dart';
import 'package:stock_q/views/widgets/secondary_button.dart';
import 'package:stock_q/views/widgets/section_spacing.dart';

class EditProfilePage extends StatefulWidget {
  final Datastore datastore;
  final Auth auth;
  EditProfilePage({this.datastore, this.auth});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _usernameTextController = TextEditingController();
  TextEditingController _addressTextController = TextEditingController();
  TextEditingController _stateTextController = TextEditingController();
  TextEditingController _cityTextController = TextEditingController();
  TextEditingController _pincodeTextController = TextEditingController();
  var userData;
  File _profileImg;
  String _profileImgUrl;
  Map<String, dynamic> deliveryAddress;
  var address, city, state, pincode;
  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  getProfileData() async {
    User user = await widget.auth.getCurrentUser();
    if (user != null) {
      userData = await widget.datastore.getUserData( user.uid);
      _usernameTextController.text = userData["name"];
      deliveryAddress = userData["deliveryAddress"];
      _addressTextController.text = deliveryAddress["address"];
      _cityTextController.text = deliveryAddress["city"];
      _stateTextController.text = deliveryAddress["state"];
      _pincodeTextController.text = deliveryAddress["pincode"];
      _profileImgUrl = userData["photoUrl"] == "" ? null : userData["photoUrl"];
    }
    setState(() {});
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _profileImg = image;
    });

    if (_profileImg != null && userData['uid'] != null) {
      String status =
          await widget.datastore.storeProfilePic(userData["uid"], _profileImg);
      log(status);

      getProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('Edit Profile', style: Custom().appbarTitleTextStyle),
          leading: IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                Navigator.pop(context, true);
              }),
        ),
        body: Container(
            child: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(children: [
                    Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(64),
                            color: Colors.grey,
                            image: _profileImgUrl != null
                                ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(_profileImgUrl))
                                : null)),
                    SizedBox(width: 32),
                    PrimaryButton('Edit', () {
                      getImage();
                    }),
                    SizedBox(width: 8),
                    SecondaryButton('Delete', () {}),
                  ]),
                  InSectionSpacing(),
                  _buildUsernameField(),
                  SectionSpacing(),
                  Text('Delivery Location'),
                  InSectionSpacing(),
                  _buildLocationField(_addressTextController, 'Address'),
                  InSectionSpacing(),
                  _buildLocationField(_stateTextController, 'State'),
                  InSectionSpacing(),
                  _buildLocationField(_cityTextController, 'City'),
                  InSectionSpacing(),
                  _buildLocationField(_pincodeTextController, 'Pincode'),
                  InSectionSpacing(),
                  PrimaryButton('Save Address', () {
                    saveLocation();
                    widget.datastore
                        .saveDeliveryLocation(userData["uid"], deliveryAddress);
                  })
                ],
              )),
        )));
  }

  saveLocation() {
    address = _addressTextController.text;
    state = _stateTextController.text;
    city = _cityTextController.text;
    pincode = _pincodeTextController.text;

    deliveryAddress = {
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode
    };
    setState(() {});
  }

  Widget _buildLocationField(TextEditingController controller, String type) {
    var hint = '';
    var t = type.toLowerCase();
    if (t == 'address') {
      hint = 'Room No / Area / Landmark';
    } else if (t == 'state') {
      hint = 'Your State';
    } else if (t == 'pincode') {
      hint = 'Your Pincode';
    } else {
      hint = 'Your city';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          type,
          style: Custom().bodyTextStyle,
        ),
        SizedBox(height: 4),
        Container(
          height: 36,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextField(
            maxLines: 1,
            style: Custom().inputTextStyle,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                hintStyle: Custom().hintTextStyle,
                border: InputBorder.none,
                hintText: hint),
            controller: controller,
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Username",
          style: Custom().bodyTextStyle,
        ),
        SizedBox(height: 4),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                height: 36,
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8)),
                child: TextField(
                  maxLines: 1,
                  style: Custom().inputTextStyle,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'yourname'),
                  controller: _usernameTextController,
                ),
              ),
            ),
            PrimaryButton('Update', () {
              var name = _usernameTextController.text.trim();
              if (name.length > 0) {
                widget.datastore.updateUserData(userData["uid"], name);
              }
            })
          ],
        )
      ],
    );
  }
}
