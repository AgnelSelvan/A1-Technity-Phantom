import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_q/models/user.dart' as UserModel;
import 'package:stock_q/models/wishlist.dart';
import 'package:stock_q/views/pages/add_product_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_q/views/pages/edit_profile_page.dart';
import 'package:stock_q/views/pages/veiw_all_products.page.dart';
import 'package:stock_q/views/pages/wishlist_page.dart';
import 'package:stock_q/views/services/auth.dart';
import 'package:stock_q/views/services/datastore.dart';
import 'package:stock_q/views/styles/custom.dart';
import 'package:stock_q/views/widgets/SectionTitle.dart';
import 'package:stock_q/views/widgets/in_section_spacing.dart';
import 'package:stock_q/views/widgets/loading.dart';
import 'package:stock_q/views/widgets/section_spacing.dart';

class ProfilePage extends StatefulWidget {
  final Auth auth;
  final Datastore datastore;
  final VoidCallback logoutCallback;
  ProfilePage({this.auth, this.datastore, this.logoutCallback});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Custom custom = Custom();
  Map<String, dynamic> userData;
  String uid;
  String _profileImgUrl;
  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  getProfileData() async {
    User user = await widget.auth.getCurrentUser();
    log(user.email);
    if (user != null) {
      userData = await widget.datastore.getUserData(user.uid);
      _profileImgUrl = userData["photoUrl"] == "" ? null : userData["photoUrl"];
      log(_profileImgUrl);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            child: userData != null
                ? Column(children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InSectionSpacing(),
                            Row(
                              children: <Widget>[
                                Container(
                                    width: 64,
                                    height: 64,
                                    child: _profileImgUrl == null
                                        ? Center(
                                            child: Text(
                                            userData["name"]
                                                .toString()
                                                .substring(0, 1),
                                            style: Custom().titleTextStyle,
                                          ))
                                        : Container(),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(64),
                                        //border: Border.all(color: Colors.black, width: 4),
                                        color: Colors.grey[100],
                                        image: _profileImgUrl != null
                                            ? DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                    _profileImgUrl))
                                            : null)),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      userData["name"],
                                      style: custom.cardTitleTextStyle,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      userData["email"],
                                      style: custom.bodyTextStyle,
                                    )
                                  ],
                                )
                              ],
                            ),
                            SectionSpacing(),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                userData['role'] == 'admin'
                                    ? ActionCard(
                                        CupertinoIcons.person_solid, "Admin",
                                        () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (BuildContext ctx) {
                                          return ViewAllProductPage(
                                            auth: widget.auth,
                                            datastore: widget.datastore,
                                          );
                                        }));
                                      })
                                    : Container(),
                                ActionCard(Icons.list, "Orders", () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext ctx) {
                                    return ViewAllProductPage(
                                      datastore: widget.datastore,
                                    );
                                  }));
                                }),
                                ActionCard(Icons.edit, "Edit", () async {
                                  bool nav = await Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (BuildContext ctx) {
                                    return EditProfilePage(
                                        auth: widget.auth,
                                        datastore: widget.datastore);
                                  }));
                                  if (nav) {
                                    getProfileData();
                                  }
                                }),
                                ActionCard(
                                    CupertinoIcons.heart_solid, "Wishlist", () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (BuildContext ctx) {
                                    return WishlistPage();
                                  }));
                                }),
                                ActionCard(Icons.exit_to_app, "Logout", () {
                                  widget.auth.signOut();
                                  widget.logoutCallback();
                                }),
                              ],
                            ),
                            SectionSpacing(),
                            SectionTitle('Shopping Information'),
                            InSectionSpacing(),
                            Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  ActionCardWithValue(Icons.credit_card,
                                      "Pending Payment", 5, () {}),
                                  ActionCardWithValue(
                                      Icons.warning, "To be shipped", 5, () {}),
                                ]),
                            InSectionSpacing(),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ActionCardWithValue(Icons.airport_shuttle,
                                    "To be Delivered", 5, () {}),
                                ActionCardWithValue(
                                    Icons.replay, "Replace/Return", 0, () {}),
                              ],
                            ),
                          ]),
                    )
                  ])
                : Loading()));
  }
}

class ActionCardWithValue extends StatelessWidget {
  final IconData icon;
  final String title;
  final int val;
  final GestureTapCallback onPressed;

  ActionCardWithValue(this.icon, this.title, this.val, this.onPressed);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5 - 24,
        height: 125,
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon),
              SizedBox(height: 8),
              Text(
                title,
                style: Custom().bodyTextStyle,
              ),
              SizedBox(height: 8),
              Text(
                val.toString(),
                style: Custom().cardTitleTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final GestureTapCallback onPressed;

  ActionCard(this.icon, this.title, this.onPressed);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onPressed,
      child: Container(
        width: 64,
        height: 48,
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
        child: Center(
          child: Icon(icon),
        ),
      ),
    );
  }
}
