import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:stock_q/resources/auth.dart';
import 'package:stock_q/resources/auth_controller.dart';
import 'package:stock_q/resources/auth_methods.dart';
import 'package:stock_q/screens/root_screen.dart';
import 'package:stock_q/screens/signup/signup.dart';
import 'package:stock_q/utils/size_utils.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/utils/utilities.dart';
import 'package:stock_q/widgets/parent_scaffold.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String emailError, passError;

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
    _authMethods.authenticateUserByEmailId(user).then((isNewUser) async {
      loading = false;
      handleState();

      AuthController authController = Get.put(AuthController());

      if (isNewUser) {
        _authMethods.addGoogleDataToDb(user).then((value) async {
          await authController.getUserData();
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return RootScreen();
          }));
        });
      } else {
        await authController.getUserData();
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
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "LOGIN",
                            style: Get.textTheme.headline4.copyWith(
                                color: Variables.primaryColor,
                                fontWeight: FontWeight.bold),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      _buildEmail(),
                      SizedBox(
                        height: 20,
                      ),
                      _buildPassword(),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                              onTap: () {},
                              child: Text(
                                "Forget Password ?",
                                style: Get.textTheme.headline6
                                    .copyWith(color: Colors.grey, fontSize: 18),
                              )),
                          RaisedButton(
                            color: Variables.primaryColor,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (emailController.text.trim().isEmpty) {
                                emailError = 'Email is Required';
                                handleState();
                                return null;
                              }

                              if (!RegExp(
                                      r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                  .hasMatch(emailController.text.trim())) {
                                emailError =
                                    'Please enter a valid email Address';
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

                              bool signedIn = await Auth.signInEmail(
                                  emailController.text.trim(),
                                  passwordController.text.trim());

                              if (signedIn) {
                                AuthController authController =
                                    Get.put(AuthController());
                                await authController.getUserData();
                                return Navigator.of(Get.context)
                                    .pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (_) => RootScreen()),
                                        (route) => false);
                              }

                              loading = false;
                              handleState();
                            },
                            child: Text(
                              "login".toUpperCase(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Don't have an account ? ",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                              onTap: () async {
                                Get.to(SignUp());
                              },
                              child: Text("Sign Up",
                                  style: TextStyle(
                                      color: Variables.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)))
                        ],
                      ),
                      SizedBox(height: 20),
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

  Widget loginButton() {
    return FlatButton(
      color: Variables.primaryColor,
      padding: EdgeInsets.all(15),
      child: Text(
        "LOGIN",
        style: TextStyle(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2),
      ),
      onPressed: () {},
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
