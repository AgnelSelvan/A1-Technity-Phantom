
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_q/constants/strings.dart';
import 'package:stock_q/models/user.dart';
import 'package:stock_q/resources/auth_controller.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/header.dart';
import 'package:stock_q/widgets/widgets.dart';

class EditScreen extends StatefulWidget {
  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController changePasswordController = TextEditingController();
  TextEditingController confirmChangePasswordController =
      TextEditingController();
  String pincode;
  bool _loading = false;
  String _confirmPassword,
      _newPassword,
      _username,
      _currentPassword,
      errorMessage,
      successMessage,
      userNameError;

  String currentUserId;
  UserModel currentUser;

  getCurrentUserDetails() async {
    // User user = await _authMethods.getCurrentUser();
    // setState(() {
    //   currentUserId = user.uid;
    // });
    // await _authMethods.getUserDetailsById(currentUserId).then((UserModel user) {
    //   setState(() {
    //     currentUser = user;
    //   });
    // });

    UserModel user = Get.find<AuthController>().userModel.value;
    //print("currentUser:${user.role}");
    setState(() {
      currentUser = user;
    });

    //print("Hahii:${currentUser.name}");
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Update Profile Photo"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                // onPressed: () => handleTakePhoto(context),
              ),
              SimpleDialogOption(
                child: Text("Image in gallery"),
                // onPressed: () => handleChooseFromGallery(context),
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  // handleTakePhoto(BuildContext context) async {
  //   Navigator.pop(context);
  //   var file = await ImagePicker.pickImage(
  //     source: ImageSource.camera,
  //     maxHeight: 675,
  //     maxWidth: 960,
  //   );
  //   setState(() {
  //     _image = file;
  //     //print(_image);
  //   });
  //   if (_image != null) {
  //     cropImageAndCompress(context);
  //   }
  // }

  // handleChooseFromGallery(BuildContext context) async {
  //   Navigator.pop(context);
  //   var file = await ImagePicker.pickImage(source: ImageSource.gallery);
  //   setState(() {
  //     _image = file;
  //     //print(_image);
  //   });
  //   if (_image != null) {
  //     // cropImageAndCompress(context);
  //     handleUploadPicture(context);
  //   }
  // }

  // cropImageAndCompress(BuildContext context) async {
  //   File croppedImage = await ImageCropper.cropImage(
  //       sourcePath: _image.path,
  //       aspectRatioPresets: [
  //         CropAspectRatioPreset.square,
  //         CropAspectRatioPreset.ratio3x2,
  //         CropAspectRatioPreset.original,
  //         CropAspectRatioPreset.ratio4x3,
  //         CropAspectRatioPreset.ratio16x9
  //       ],
  //       androidUiSettings: AndroidUiSettings(
  //           toolbarTitle: 'Cropper',
  //           toolbarColor: Colors.deepOrange,
  //           toolbarWidgetColor: Colors.white,
  //           initAspectRatio: CropAspectRatioPreset.original,
  //           lockAspectRatio: false),
  //       iosUiSettings: IOSUiSettings(
  //         minimumAspectRatio: 1.0,
  //       ));

  //   //print("Crop Size:${_image.lengthSync()}");

  //   // File result = await FlutterImageCompress.compressAndGetFile(
  //   //     croppedImage.path, _image.path,
  //   //     quality: 88);
  //   String image;
  //   var result = await FlutterImageCompress.compressAndGetFile(
  //     croppedImage.path,
  //     image,
  //     quality: 88,
  //     rotate: 180,
  //   );

  //   //print(croppedImage.lengthSync());
  //   //print(result.lengthSync());

  //   //print(result.path);
  //   // handleUploadPicture(context);
  // }

  // handleUploadPicture(BuildContext context) async {
  //   setState(() {
  //     _loading = true;
  //   });
  //   _deleteImageFromFirestorage();
  //   String photoUrl = await uploadImage();
  //   Firestore.instance
  //       .collection('users')
  //       .document(currentUser.uid)
  //       .updateData({"photoUrl": photoUrl}).then((onValue) {
  //     buildSuccessDialog("Profile Picture Update Successfull!", context);
  //   }).catchError((onError) {
  //     buildErrorDialog(onError.message, context);
  //   });
  //   getCurrentUserInfo();
  //   setState(() {
  //     _loading = false;
  //   });
  // }

  // Future<String> uploadImage() async {
  //   String fileName = basename(_image.path);
  //   StorageReference firebaseStorageRef =
  //       FirebaseStorage.instance.ref().child(fileName);
  //   StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
  //   StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  //   String downloadUrl = await taskSnapshot.ref.getDownloadURL();
  //   return downloadUrl;
  // }

  // _deleteImageFromFirestorage() async {
  //   var fileUrl = Uri.decodeFull(basename(currentUser.photoUrl))
  //       .replaceAll(new RegExp(r'(\?alt).*'), '');
  //   // //print(fileUrl);
  //   var downloadUrl = FirebaseStorage.instance.ref().child(fileUrl).getName();
  //   if (downloadUrl != null) {
  //     FirebaseStorage.instance
  //         .ref()
  //         .child(fileUrl)
  //         .delete()
  //         .then((value) {})
  //         .catchError((onError) {
  //       //print(onError.message);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    TextEditingController userNameController =
        TextEditingController(text: currentUser.username ?? '');

    Widget _buildUsername(String username) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Username",
            style: Variables.inputLabelTextStyle,
          ),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8)),
            child: TextField(
              maxLines: 1,
              style: Variables.inputTextStyle,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  errorText: userNameError,
                  border: InputBorder.none,
                  hintText: 'Your name'),
              controller: userNameController,
            ),
          )
        ],
      );
    }

    Widget _buildCurrentPassword() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            maxLines: 1,
            style: Variables.inputTextStyle,
            controller: currentPasswordController,
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'Current Password',
            ),
            keyboardType: TextInputType.visiblePassword,
            validator: (String value) {
              if (value.isEmpty) {
                return 'Password is Required';
              }
              if (value.length < 6) {
                return 'Your password needs to be atleast 6 character';
              }

              return null;
            },
            onSaved: (String value) {
              _currentPassword = value;
            },
            obscureText: true,
          ),
        ),
      );
    }

    Widget _buildChangePassword() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            controller: changePasswordController,
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'New Password',
            ),
            keyboardType: TextInputType.visiblePassword,
            validator: (String value) {
              if (value.isEmpty) {
                return 'Password is Required';
              }
              if (value.length < 6) {
                return 'Your password needs to be atleast 6 character';
              }

              return null;
            },
            onSaved: (String value) {
              _newPassword = value;
            },
            obscureText: true,
          ),
        ),
      );
    }

    Widget _buildConfirmChangePassword() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            controller: confirmChangePasswordController,
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'Confirm Password',
            ),
            keyboardType: TextInputType.visiblePassword,
            validator: (String value) {
              if (value.isEmpty) {
                return 'Password is Required';
              }
              if (value.length < 6) {
                return 'Your password needs to be atleast 6 character';
              }

              return null;
            },
            onSaved: (String value) {
              _confirmPassword = value;
            },
            obscureText: true,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Variables.lightGreyColor,
      appBar: CustomAppBar(
          title: Text("Stock Q", style: Variables.appBarTextStyle),
          actions: null,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Variables.primaryColor,
                size: 16,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          centerTitle: true,
          bgColor: Colors.white),
      body: Container(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          children: <Widget>[
            BuildHeader(
              text: "Edit Profile",
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildText("Profile Picture", Colors.black26),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => ViewImage(
                          //               image: currentUser.photoUrl,
                          //             )));
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: currentUser.profilePhoto == null ||
                                  currentUser.profilePhoto == ""
                              ? AssetImage('assets/images/unknown-user.png')
                              : CachedNetworkImageProvider(
                                  currentUser.profilePhoto),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      buildRaisedButton("Upload New Picture",
                          Colors.yellow[100], Variables.blackColor, () {
                        selectImage(context);
                      }),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        child: currentUser.profilePhoto == ""
                            ? Text("")
                            : IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  // _deleteProfilePhoto();
                                }),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  _buildUsername(currentUser.username),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      buildRaisedButton("Save Changes", Colors.yellow[100],
                          Variables.blackColor, () {
                        // _updateUsername();

                        if (userNameController.text.isEmpty) {
                          setState(() {
                            userNameError = "Username cant be empty";
                          });
                          return;
                        }

                        if (userNameController.text == currentUser.username) {
                          setState(() {
                            userNameError = " Username is same as old";
                          });
                          return;
                        }

                        setState(() {
                          userNameError = null;
                        });

                        FirebaseFirestore.instance
                            .collection(USERS_COLLECTION)
                            .doc(currentUser.uid)
                            .update(
                                {"username": userNameController.text.trim()});
                      }),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 20),
            BuildHeader(text: "Change Password"),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10),
                  _buildCurrentPassword(),
                  SizedBox(height: 20),
                  SizedBox(height: 10),
                  _buildChangePassword(),
                  SizedBox(height: 10),
                  SizedBox(height: 10),
                  _buildConfirmChangePassword(),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      buildRaisedButton("Save Changes", Colors.yellow[100],
                          Variables.blackColor, () {
                        // _updatePassword();
                      }),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Text buildText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
          letterSpacing: 1,
          fontSize: 20,
          color: color,
          fontWeight: FontWeight.bold),
    );
  }
}
