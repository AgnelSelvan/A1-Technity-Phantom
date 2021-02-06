import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:stock_q/models/user.dart';
import 'package:stock_q/services/auth.dart';
import 'package:stock_q/services/datastore.dart';
import 'package:stock_q/views/styles/custom.dart';
import 'package:stock_q/views/widgets/appbar.dart';
import 'package:stock_q/views/widgets/link_button.dart';
import 'package:stock_q/views/widgets/primary_button.dart';

class AuthPage extends StatefulWidget {
  final VoidCallback loginCallback;
  final BaseAuth auth;
  final BaseDatastore datastore;
  AuthPage({this.auth, this.datastore, this.loginCallback});
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _usernameTextController = TextEditingController();
  var _email, _password, _username;
  var _photoUrl = 'hello';
  final formKey = GlobalKey<FormState>();
  var toggleSignUp = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(title: toggleSignUp ? 'Sign up' : 'Login'),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Form(
            key: formKey,
            child: ListView(children: [
              toggleSignUp
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildUsernameField(),
                    )
                  : Container(),
              _buildEmailField(),
              SizedBox(height: 16),
              _buildPasswordField(),
              SizedBox(height: 24),
              _authActions(),
              SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(!toggleSignUp
                    ? 'Not have an account ? '
                    : 'Already have an account ? '),
                LinkButton(!toggleSignUp ? 'Sign up' : 'Login', () {
                  setState(() {
                    toggleSignUp = !toggleSignUp;
                  });
                })
              ])
            ]),
          ),
        ));
  }

  Widget _authActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        toggleSignUp
            ? PrimaryButton("Sign up", () {
                validateAndSubmit();
              })
            : PrimaryButton("Login", () {
                validateAndSubmit();
              }),
        !toggleSignUp ? LinkButton("Forgot Password ?", () {}) : Container()
      ],
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Username",
          style: Custom().inputLabelTextStyle,
        ),
        SizedBox(height: 4),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            maxLines: 1,
            style: Custom().inputTextStyle,
            keyboardType: TextInputType.emailAddress,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: 'yourname'),
            controller: _usernameTextController,
            validator: (value) =>
                value.isEmpty ? 'Username can\'t be empty' : null,
            onSaved: (value) => _username = value.trim(),
          ),
        )
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Email Address",
          style: Custom().inputLabelTextStyle,
        ),
        SizedBox(height: 4),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            maxLines: 1,
            style: Custom().inputTextStyle,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: 'you@gmail.com'),
            controller: _emailTextController,
            validator: (value) =>
                value.isEmpty ? 'Email can\'t be empty' : null,
            onSaved: (value) => _email = value.trim(),
          ),
        )
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Password",
          style: Custom().inputLabelTextStyle,
        ),
        SizedBox(height: 4),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            keyboardType: TextInputType.visiblePassword,
            style: Custom().inputTextStyle,
            obscureText: true,
            maxLines: 1,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: 'your password'),
            controller: _passwordTextController,
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

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    log('not validated');

    if (validateAndSave()) {
      log('validated');
      String userId = "";
      try {
        if (!toggleSignUp) {
          userId = await widget.auth.signIn(_email, _password);
          print('Signed in $userId');
        } else {
          log(_username);
          log(_email);
          log(_photoUrl);
          userId = await widget.auth.signUp(_email, _password);
          widget.datastore.addUserData(
              User(uid: userId, username: _username, email: _email));
          print('signed up $userId');
        }

        if (userId != null && userId.length > 0) {
          widget.loginCallback();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          formKey.currentState.reset();
        });
      }
    }
  }
}
