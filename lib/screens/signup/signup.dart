import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:stock_q/resources/auth.dart';
import 'package:stock_q/resources/auth_methods.dart';
import 'package:stock_q/screens/root_screen.dart';
import 'package:stock_q/utils/size_utils.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/utils/utilities.dart';
import 'package:stock_q/widgets/parent_scaffold.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();

  String emailError, passError, usernameError;

  bool loading = false;

  AuthMethods _authMethods = AuthMethods();

  handleState() async {
    if (!mounted) return false;
    setState(() {});
    return true;
  }

  void performGoogleLogin() {
    loading = true;
    handleState();

    _authMethods.googleSignIn().then((User user) {
      if (user == null) {
        Utils.showSnackBar(text: 'Error Signing In!', bgColor: Colors.red[800]);
      }
      if (user != null) {
        //print('user.phoneNumber: ${user.phoneNumber}');
        authenticateUserByGoogleLogin(user);
      } else {
        //print("There was an error");
      }
    });
    loading = false;
    handleState();
  }

  void authenticateUserByGoogleLogin(User user) {
    _authMethods.authenticateUserByEmailId(user).then((isNewUser) {
      loading = false;
      handleState();

      if (isNewUser) {
        _authMethods.addGoogleDataToDb(user).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return RootScreen();
          }));
        });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return RootScreen();
        }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ParentScaffold(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 250),
        child: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                margin: EdgeInsets.symmetric(
                  horizontal: SizeUtils.marginHorizontal,
                ),
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "SIGN UP",
                            style: TextStyle(
                                color: Variables.primaryColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          )),
                      SizedBox(height: 20),
                      _buildUsername(),
                      SizedBox(
                        height: 20,
                      ),
                      _buildEmail(),
                      SizedBox(
                        height: 20,
                      ),
                      _buildPassword(),
                      SizedBox(
                        height: 20,
                      ),
                      RaisedButton(
                        color: Variables.primaryColor,
                        onPressed: () async {
                          loading = true;
                          handleState();

                          if (userNameController.text.trim().isEmpty) {
                            usernameError = 'Username cant be empty';
                            handleState();
                            return null;
                          }

                          usernameError = null;

                          if (emailController.text.trim().isEmpty) {
                            emailError = 'Email is Required';
                            handleState();
                            return null;
                          }

                          if (!RegExp(
                                  r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                              .hasMatch(emailController.text.trim())) {
                            emailError = 'Please enter a valid email Address';
                            handleState();
                            return null;
                          }

                          emailError = null;

                          if (passwordController.text.trim().isEmpty) {
                            passError = 'Passwords can\'t be empty';
                            handleState();
                            return null;
                          }

                          if (passwordController.text.trim().length < 6) {
                            passError =
                                'Passwords should be at least 6 characters';
                            handleState();
                            return null;
                          }

                          passError = null;

                          loading = true;

                          handleState();

                          try {
                            var result = await Auth.auth
                                .createUserWithEmailAndPassword(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim());

                            User user = result.user;

                            if (user != null) {
                              bool newUser = await _authMethods
                                  .authenticateUserByEmailId(user);

                              if (newUser) {
                                await _authMethods.addUserDataToDb(
                                    user, userNameController.text);
                              }

                              Navigator.of(Get.context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) => RootScreen()),
                                  (route) => false);
                            } else {
                              loading = false;
                              handleState();
                              Utils.showSnackBar(
                                  text: 'Error SignUp',
                                  bgColor: Colors.red.shade800);
                            }
                          } catch (e) {
                            loading = false;
                            handleState();
                            FirebaseAuthException exception = e;
                            log(exception.message);
                            Utils.showSnackBar(text: exception.message);
                          }
                        },
                        child: Text(
                          "SIGN UP",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Already have an account ? ",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          SizedBox(width: 10),
                          InkWell(
                              onTap: () {
                                Get.back();
                              },
                              child: Text("LOGIN",
                                  style: TextStyle(
                                      color: Variables.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                          SizedBox(height: 20),
                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                                icon: Icon(
                                  FontAwesome.google,
                                  color: Colors.orange,
                                ),
                                onPressed: () {
                                  performGoogleLogin();
                                }),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: IconButton(
                                icon: Icon(
                                  Icons.mail,
                                  color: Colors.white,
                                ),
                                onPressed: () {}),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildUsername() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Username",
          style: Variables.inputLabelTextStyle,
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextField(
            maxLines: 1,
            style: Variables.inputTextStyle,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                errorText: usernameError,
                border: InputBorder.none,
                hintText: 'Your Name'),
            controller: userNameController,
          ),
        )
      ],
    );
  }

  Widget _buildEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Email Address",
          style: Variables.inputLabelTextStyle,
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: emailController,
            maxLines: 1,
            style: Variables.inputTextStyle,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                errorText: emailError,
                border: InputBorder.none,
                hintText: 'you@gmail.com'),
          ),
        ),
      ],
    );
  }

  //Password TextField
  Widget _buildPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Password",
          style: Variables.inputLabelTextStyle,
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextField(
            keyboardType: TextInputType.visiblePassword,
            style: Variables.inputTextStyle,
            obscureText: true,
            maxLines: 1,
            decoration: InputDecoration(
                errorText: passError,
                border: InputBorder.none,
                hintText: 'Your password'),
            controller: passwordController,
          ),
        )
      ],
    );
  }
}
