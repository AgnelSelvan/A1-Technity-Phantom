import 'package:annaistore/resources/auth_methods.dart';
import 'package:annaistore/screens/root_screen.dart';
import 'package:annaistore/utils/universal_variables.dart';
import 'package:annaistore/widgets/dialogs.dart';
import 'package:annaistore/widgets/widgets.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final AuthMethods _authMethods = AuthMethods();
  String _password;
  String _email;
  String _username;
  bool isNew = false;
  String countryCode = '+91';

  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool viewPhoneVisible = false;
  bool viewGoogleVisible = false;
  bool viewEmailVisible = true;

  void mobileLogin() {
    _auth.verifyPhoneNumber(
        phoneNumber: '$countryCode${phoneNumberController.text}'.trim(),
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          Navigator.pop(context);
          AuthResult authResult = await _auth.signInWithCredential(credential);
          FirebaseUser user = authResult.user;
          if (user != null) {
            authenticateUserByPhoneLogin(user);
            //print(user.phoneNumber);
            //print("Login In");
          }
        },
        verificationFailed: (AuthException authException) {
          Dialogs.okDialog(
              context, 'Error', authException.message, Colors.red[200]);
          //print(authException.message);
        },
        codeSent: (String verificationId, [int forceResendingCode]) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  title: Text("Enter Code"),
                  content: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(8)),
                    child: TextFormField(
                      cursorColor: Variables.primaryColor,
                      validator: (value) {
                        if (value.isEmpty)
                          return "You cannot have an empty code!";
                      },
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      style: Variables.inputTextStyle,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: '*****'),
                      controller: codeController,
                    ),
                  ),
                  actions: <Widget>[
                    buildRaisedButton('Confirm'.toUpperCase(), Colors.white,
                        Variables.primaryColor, () async {
                      final code = codeController.text.trim();
                      AuthCredential credential =
                          PhoneAuthProvider.getCredential(
                              verificationId: verificationId, smsCode: code);

                      AuthResult result =
                          await _auth.signInWithCredential(credential);

                      FirebaseUser user = result.user;
                      if (user != null) {
                        authenticateUserByPhoneLogin(user);
                        //print("Login In");
                      } else {
                        //print("Erro");
                      }
                      Navigator.pop(context);
                      codeController.clear();
                    })
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: null);
  }

  authenticateUserByPhoneLogin(FirebaseUser user) {
    _authMethods.authenticateUserByPhone(user).then((isNewUser) {
      setState(() {
        isLoading = false;
      });

      if (isNewUser) {
        _authMethods.addPhoneDataToDb(user).then((value) {
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

  checkInternet() async {
    DataConnectionStatus checker = await _authMethods.checkInternet();
    if (checker == DataConnectionStatus.disconnected) {
      Dialogs.okDialog(
          context, 'Error', 'No Internet Connection!', Colors.red[200]);
    }
  }

  @override
  void initState() {
    super.initState();
    checkInternet();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // viewPhoneVisible ? buildPhoneUI() : Container(),
            viewEmailVisible ? isNew ? signUp() : login() : Container(),
            Column(
              children: [
                SizedBox(height: 15),
                Text(
                  "OR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // CircleAvatar(
                      //   backgroundColor: Colors.blue,
                      //   child: IconButton(
                      //       icon: Icon(
                      //         Icons.phone,
                      //         color: Colors.white,
                      //       ),
                      //       onPressed: () {
                      //         setState(() {
                      //           viewEmailVisible = false;
                      //           viewPhoneVisible = true;
                      //         });
                      //       }),
                      // ),
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
                            onPressed: () {
                              setState(() {
                                viewEmailVisible = true;
                                viewPhoneVisible = false;
                              });
                            }),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
    // return Scaffold(
    //   body: Stack(
    //     children: [
    //       Center(
    //         child: isNew ? signUp() : login(),
    //       ),
    //       isLoading
    //           ? Center(
    //               child: CustomCircularLoading(),
    //             )
    //           : Container()
    //     ],
    //   ),
    // );
  }

  buildPhoneUI() {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: viewPhoneVisible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Phone",
                    style: TextStyle(
                        fontSize: 28,
                        color: Variables.primaryColor,
                        fontWeight: FontWeight.bold),
                  )),
              SizedBox(height: 20),
              Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          Container(
                            child: CountryCodePicker(
                              onChanged: (CountryCode value) {
                                setState(() {
                                  countryCode = value.dialCode;
                                });
                              },
                              initialSelection: '+91',
                              favorite: ['+91', 'IND'],
                              showCountryOnly: false,
                              // optional. Shows only country name and flag when popup is closed.
                              showOnlyCountryWhenClosed: false,
                              onInit: (code) => print(
                                  "on init ${code.name} ${code.dialCode} ${code.name}"),
                              alignLeft: false,
                            ),
                          ),
                          buildPhoneNumberField(),
                        ],
                      ),
                      SizedBox(height: 20),
                      buildRaisedButton('Login'.toUpperCase(),
                          Variables.primaryColor, Colors.white, () {
                        if (_formKey.currentState.validate()) {
                          //print(countryCode);
                          mobileLogin();
                        }
                      }),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  buildPhoneNumberField() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Mobile Number",
            style: Variables.inputLabelTextStyle,
          ),
          SizedBox(height: 4),
          Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              controller: phoneNumberController,
              maxLines: 1,
              keyboardType: TextInputType.number,
              style: Variables.inputTextStyle,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: '123456789'),
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Mobile number is Required';
                }
                if (value.length != 10) {
                  return 'Invalid Mobile number!';
                }

                return null;
              },
            ),
          ),
        ],
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
        SizedBox(height: 4),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            maxLines: 1,
            style: Variables.inputTextStyle,
            keyboardType: TextInputType.emailAddress,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: 'yourname'),
            controller: userNameController,
            validator: (value) =>
                value.isEmpty ? 'Username can\'t be empty' : null,
            onSaved: (value) => _username = value.trim(),
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
        SizedBox(height: 4),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            controller: emailController,
            maxLines: 1,
            style: Variables.inputTextStyle,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: 'you@gmail.com'),
            validator: (String value) {
              if (value.isEmpty) {
                return 'Email is Required';
              }

              if (!RegExp(
                      r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                  .hasMatch(value)) {
                return 'Please enter a valid email Address';
              }

              return null;
            },
            onSaved: (String value) {
              _email = value;
            },
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
        SizedBox(height: 4),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            keyboardType: TextInputType.visiblePassword,
            style: Variables.inputTextStyle,
            obscureText: true,
            maxLines: 1,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: 'your password'),
            controller: passwordController,
            validator: (value) {
              if (value.isEmpty)
                return 'Passwords can\'t be empty';
              else if (value.length < 6)
                return 'Passwords should be atleast 6 characters';
              else
                return null;
            },
            onSaved: (value) => _password = value.trim(),
          ),
        )
      ],
    );
  }

  Widget login() {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: viewEmailVisible,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "LOGIN",
                    style: TextStyle(
                        fontSize: 28,
                        color: Variables.primaryColor,
                        fontWeight: FontWeight.bold),
                  )),
              SizedBox(height: 20),
              Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      _buildEmail(),
                      _buildPassword(),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          RaisedButton(
                            color: Variables.primaryColor,
                            textColor: Colors.white,
                            onPressed: () {
                              _authMethods
                                  .signIn(emailController.text,
                                      passwordController.text)
                                  .then((bool isSignedIn) {
                                if (isSignedIn) {
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    return RootScreen();
                                  }));
                                } else {
                                  Dialogs.okDialog(context, "Error",
                                      "Error Signing In", Colors.red[200]);
                                }
                              });
                            },
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: GestureDetector(
                                onTap: () {},
                                child: Text(
                                  "Forget Password ?",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 18),
                                )),
                          )
                        ],
                      ),
                      SizedBox(height: 5),
                    ],
                  )),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Not have an account ? ",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                      onTap: () async {
                        setState(() {
                          isNew = true;
                        });
                      },
                      child: Text("Sign Up",
                          style: TextStyle(
                              color: Variables.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget signUp() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
            Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildUsername(),
                    SizedBox(height: 10),
                    _buildEmail(),
                    SizedBox(height: 10),
                    _buildPassword(),
                    SizedBox(height: 20),
                    RaisedButton(
                      color: Variables.primaryColor,
                      onPressed: () {
                        _authMethods
                            .signUp(
                                emailController.text, passwordController.text)
                            .then((FirebaseUser user) {
                          _authMethods
                              .authenticateUserByEmailId(user)
                              .then((isNewUser) {
                            if (isNewUser) {
                              _authMethods
                                  .addUserDataToDb(
                                      user, userNameController.text)
                                  .then((value) {
                                setState(() {
                                  userNameController.clear();
                                  isNew = false;
                                });
                              });
                            }
                          });
                        });
                      },
                      child: Text(
                        "SIGN UP",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                )),
            SizedBox(height: 15),
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
                GestureDetector(
                    onTap: () {
                      setState(() {
                        isNew = false;
                      });
                    },
                    child: Text("LOGIN",
                        style: TextStyle(
                            color: Variables.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)))
              ],
            )
          ],
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
      onPressed: () => performGoogleLogin(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  void performGoogleLogin() {
    //print("tring to perform login");

    setState(() {
      isLoading = true;
    });

    _authMethods.googleSignIn().then((FirebaseUser user) {
      if (user == null) {
        Dialogs.okDialog(
            context, 'Error', 'Error Signing In!', Colors.red[200]);
      }
      if (user != null) {
        //print('user.phoneNumber: ${user.phoneNumber}');
        authenticateUserByGoogleLogin(user);
      } else {
        //print("There was an error");
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  void authenticateUserByGoogleLogin(FirebaseUser user) {
    _authMethods.authenticateUserByEmailId(user).then((isNewUser) {
      setState(() {
        isLoading = false;
      });

      if (isNewUser) {
        _authMethods.addGoogleDataToDb(user).then((value) {
          updateMobileNumber(user);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return RootScreen();
          }));
        });
      } else {
        updateMobileNumber(user);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return RootScreen();
        }));
      }
    });
  }

  updateMobileNumber(FirebaseUser user) {
    _authMethods.isPhoneNoExists(user).then((bool isPhoneExists) {
      if (!isPhoneExists) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                title: Text("Enter Code"),
                content: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(8)),
                  child: TextFormField(
                    cursorColor: Variables.primaryColor,
                    validator: (value) {
                      if (value.isEmpty)
                        return "You cannot have an Mobile number!";
                    },
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    style: Variables.inputTextStyle,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: '1234567890'),
                    controller: phoneNumberController,
                  ),
                ),
                actions: <Widget>[
                  buildRaisedButton('Confirm'.toUpperCase(), Colors.white,
                      Variables.primaryColor, () async {
                    _authMethods.updateMobileNumber(
                        phoneNumberController.text, user);
                    Navigator.pop(context);
                    phoneNumberController.clear();
                  })
                ],
              );
            });
      }
    });
  }
}
