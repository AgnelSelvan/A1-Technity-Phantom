import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:stock_q/models/user.dart';
import 'package:stock_q/resources/auth_methods.dart';
import 'package:stock_q/screens/custom_loading.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/dialogs.dart';
import 'package:stock_q/widgets/widgets.dart';

AuthMethods _authMethods = AuthMethods();

class MakeAdminScreen extends StatefulWidget {
  @override
  _MakeAdminScreenState createState() => _MakeAdminScreenState();
}

class _MakeAdminScreenState extends State<MakeAdminScreen> {
  UserModel currentSelectedUser;
  TextEditingController emailController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
      // drawer: widget.currentUser != null
      //     ? AdminDrawer(
      //         currentUser: widget.currentUser,
      //         orderCount: _orderCount,
      //       )
      //     : null,
      body: Center(
        child: userListDropDown(),
      ),
    );
  }

  Widget userListDropDown() {
    return Container(
      width: 500,
      padding: EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Make Admin",
            style: Theme.of(context).textTheme.headline,
          ),
          SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
              stream: _authMethods.getAllUserWithUserRole(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  //print(snapshot.error);
                } else {
                  if (!snapshot.hasData) {
                    return CustomCircularLoading();
                  }

                  if (snapshot.data.docs.length == 0) {
                    return Text("No User exists to select admin");
                  }
                  return new DropdownButton<DocumentSnapshot>(
                    onChanged: (DocumentSnapshot newValue) async {
                      UserModel user = UserModel.fromMap(newValue.data());
                      setState(() {
                        currentSelectedUser = user;
                      });
                    },
                    hint: currentSelectedUser == null
                        ? Text('Select Admin')
                        : Text(currentSelectedUser.name),
                    items: snapshot.data.docs
                        .map((DocumentSnapshot document) {
                      return new DropdownMenuItem<DocumentSnapshot>(
                          value: document,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              new Text(
                                document.data()['email'],
                              ),
                              new Text(
                                "(${document.data()['name']})",
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ));
                    }).toList(),
                  );
                }
                return CustomCircularLoading();
              }),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              buildRaisedButton("Back", Colors.white, Variables.primaryColor,
                      () {
                    Navigator.pop(context);
                  }),
              buildRaisedButton(
                  "Make Admin", Variables.primaryColor, Colors.white, () {
                makeAdmin();
              }),
            ],
          )
        ],
      ),
    );
  }

  makeAdmin() async {
    //print(currentSelectedUser);
    if (currentSelectedUser == null) {
      Dialogs.okDialog(context, 'Error', 'No User Selected', Colors.red[200]);
    } else {
      bool isSuccess = await _authMethods.makeAdmin(currentSelectedUser.uid);
      if (isSuccess) {
        Dialogs.okDialog(
            context, 'Sucessfull', "Updated Successfully", Colors.green[200]);
        final snackBar = SnackBar(
          content: Text(
            'Demote Admin',
            style: TextStyle(color: Variables.blackColor),
          ),
          action: SnackBarAction(
              label: "Undo",
              textColor: Colors.red[200],
              onPressed: () {
                _authMethods.demoteAdminToUser(currentSelectedUser.uid);
              }),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.yellow[100],
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      } else {
        Dialogs.okDialog(context, 'Error',
            'Error! select User again to make admin', Colors.red[200]);
      }
    }
  }
}

class DrawerIcon extends StatelessWidget {
  const DrawerIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: 26,
                  decoration: new BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          width: 1.2, color: Theme.of(context).primaryColor),
                      left: BorderSide(
                          width: 1.2, color: Theme.of(context).primaryColor),
                      right: BorderSide(
                          width: 1.2, color: Theme.of(context).primaryColor),
                      bottom: BorderSide(
                          width: 1.2, color: Theme.of(context).primaryColor),
                    ),
                  )),
              SizedBox(height: 4),
              Container(
                  alignment: Alignment.topLeft,
                  width: 20,
                  decoration: new BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          width: 1.2, color: Theme.of(context).primaryColor),
                      left: BorderSide(
                          width: 1.2, color: Theme.of(context).primaryColor),
                      right: BorderSide(
                          width: 1.2, color: Theme.of(context).primaryColor),
                      bottom: BorderSide(
                          width: 1.2, color: Theme.of(context).primaryColor),
                    ),
                  )),
              SizedBox(height: 4),
              Container(
                  width: 26,
                  decoration: new BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          width: 1.2, color: Theme.of(context).primaryColor),
                      left: BorderSide(
                          width: 1.2, color: Theme.of(context).primaryColor),
                      right: BorderSide(
                          width: 1.2, color: Theme.of(context).primaryColor),
                      bottom: BorderSide(
                          width: 1.2, color: Theme.of(context).primaryColor),
                    ),
                  )),
              SizedBox(height: 4),
            ],
          ),
        ));
  }
}

class AdminDrawer extends StatelessWidget {
  UserModel currentUser;
  int orderCount;

  AdminDrawer({this.currentUser, this.orderCount});

  @override
  Widget build(BuildContext context) {
    List<String> data = [
      "Dashboard",
      "Order Request",
      "Delivered Product",
      "Upload Product",
      "Delete Product",
      "Update Product",
      "View Product",
      "Online Transaction"
    ];
    List<IconData> icon = [
      FontAwesome.list_alt,
      FontAwesome.cart_arrow_down,
      FontAwesome.truck,
      FontAwesome.upload,
      Icons.delete,
      Icons.update,
      Icons.view_array,
      Icons.payment
    ];
    List<GestureTapCallback> onPressed = [
          () {
        Navigator.pop(context);
      },
          () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => OrderPage(
        //               currentUser: currentUser,
        //             )));
      },
          () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => DeliveredPage(
        //               currentUser: currentUser,
        //             )));
      },
          () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => UploadPage(
        //               currentUser: currentUser,
        //             )));
      },
          () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => DeletePage(
        //               currentUser: currentUser,
        //             )));
      },
          () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => ViewPage(
        //               isUpdate: 'true',
        //               currentUser: currentUser,
        //             )));
      },
          () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => ViewPage(
        //               currentUser: currentUser,
        //             )));
      },
          () {
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => OrderTransaction(
        //               currentUser: currentUser,
        //             )));
      }
    ];
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xffECECEC)),
              accountName: Text(
                currentUser.username,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                'currentUser.userEmail',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                CachedNetworkImageProvider('currentUser.photoUrl'),
              )),
          Container(
            height: double.maxFinite,
            child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, i) {
                  return new ListTile(
                    title: new Text(data[i]),
                    leading: orderCount != 0 && data[i] == 'Order Request'
                        ? Stack(
                      children: <Widget>[
                        Icon(icon[i]),
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: Container(
                            width: 15,
                            height: 15,
                            alignment: Alignment.center,
                            // padding: EdgeInsets.symmetric(
                            //     horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              orderCount.toString(),
                              style: TextStyle(
                                  fontSize: 11, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    )
                        : Icon(icon[i]),
                    onTap: onPressed[i],
                  );
                }),
          )
        ],
      ),
    );
  }
}
