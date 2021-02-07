import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:stock_q/flutter_barcode_scanner.dart';
import 'package:stock_q/models/user.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/resources/auth_methods.dart';
import 'package:stock_q/screens/admin/add/add_product.dart';
import 'package:stock_q/screens/admin/product_details.dart';
import 'package:stock_q/screens/canvas_screen.dart';
import 'package:stock_q/screens/map_screen.dart';
import 'package:stock_q/screens/thread_screen.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/bouncy_page_route.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/map.dart';
import 'package:stock_q/widgets/widgets.dart';

AdminMethods _adminMethods = AdminMethods();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;
  final AuthMethods _authMethods = AuthMethods();
  TextEditingController phoneNumberController = TextEditingController();
  String currentUserId;
  UserModel currentUser;
  bool isDarkTheme = false;
  var darkModeOn = false;

  getCurrentUserDetails() async {
    User user = await _authMethods.getCurrentUser();
    _authMethods.isPhoneNoExists(user).then((bool isPhoneExists) {
      //print('isPhoneExists:$isPhoneExists');
      if (!isPhoneExists) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                title: Text("Enter Mobile number"),
                content: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8)),
                  child: TextFormField(
                    cursorColor: Variables.primaryColor,
                    validator: (value) {
                      if (value.isEmpty)
                        return "You cannot have an Mobile number!";
                      return null;
                    },
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    style: Variables.inputTextStyle,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.dialpad,
                          size: 16,
                        ),
                        border: InputBorder.none,
                        hintText: '1234567890'),
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

    currentUserId = user.uid;
    currentUser = await _authMethods.getUserDetailsById(currentUserId);
    //print('user:${currentUser.role}');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        bgColor: isDarkTheme
            ? Theme.of(context).primaryColorDark
            : Variables.lightGreyColor,
        title: Text("Stock Q",
            style: TextStyle(
                fontSize: 20,
                letterSpacing: 1,
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.w400)),
        actions: [
          IconButton(
              icon: Icon(FontAwesome.qrcode,
                  color: Theme.of(context).accentColor),
              onPressed: () => scanQR())
        ],
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 10,
            backgroundColor: Theme.of(context).primaryColor,
            backgroundImage: isDarkTheme
                ? AssetImage('assets/images/logo/dark-theme-logo.png')
                : AssetImage('assets/images/logo/light-theme-logo.png'),
            child: GestureDetector(
              onDoubleTap: () async {
                // isDarkTheme = !isDarkTheme;
                // if (isDarkTheme) {
                //   themeNotifier.setTheme(darkTheme);
                // } else {
                //   themeNotifier.setTheme(lightTheme);
                // }
                // var prefs = await SharedPreferences.getInstance();
                // prefs.setBool('darkMode', isDarkTheme);

                // //print("Dark Theme");
              },
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: buildBody(context),
      ),
    );
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      //print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;
    final bool isQrExists = await _adminMethods.isQrExists(barcodeScanRes);
    if (isQrExists) {
      Navigator.push(
          context,
          BouncyPageRoute(
              widget: ProductDetails(
                qrCode: barcodeScanRes,
              )));
    } else if (!isQrExists) {
      currentUser.role == 'admin'
          ? Navigator.push(
          context,
          BouncyPageRoute(
              widget: AddProduct(
                qrCode: barcodeScanRes,
              )))
          : Text("No Items");
    }
  }

  ListView buildBody(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(left: 10.0),
      children: <Widget>[
        SizedBox(height: 15.0),
        Text('Categories',
            style: TextStyle(
                fontSize: 28.0,
                color: Variables.blackColor,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 15.0),
        TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            labelColor: Theme.of(context).accentColor,
            isScrollable: false,
            labelPadding: EdgeInsets.only(right: 45.0),
            unselectedLabelColor: Color(0xFFCDCDCD),
            tabs: [
              Tab(
                child: Text('Threads',
                    style: TextStyle(
                      fontSize: 18.0,
                    )),
              ),
              Tab(
                child: Text('Paper Canvas',
                    style: TextStyle(
                      fontSize: 18.0,
                    )),
              ),
              Tab(
                child: Text('Rolls',
                    style: TextStyle(
                      fontSize: 18.0,
                    )),
              )
            ]),
        Container(
            height: MediaQuery.of(context).size.height / 2.3,
            width: double.infinity,
            child: TabBarView(controller: _tabController, children: [
              ThreadScreen(),
              CanvasScreen(),
              ThreadScreen(),
            ])),
        SizedBox(height: 15.0),
        GestureDetector(
          onTap: () {
            Navigator.push(context, BouncyPageRoute(widget: MapScreen()));
          },
          child: Text('Location',
              style: TextStyle(
                  fontSize: 28.0,
                  color: Variables.blackColor,
                  fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 15.0),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 300,
          child: BuildMap(),
        )
      ],
    );
  }
}
