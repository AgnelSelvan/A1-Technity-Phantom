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
import 'package:stock_q/screens/bag_screen.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/bouncy_page_route.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
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

    currentUserId = user.uid;
    _authMethods.getUserDetailsById(currentUserId).then((value){
      setState(() {
        currentUser = value;
      });
    });
    //print('user:${currentUser.role}');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    getCurrentUserDetails();
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
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w400)),
                leading: null,
        actions: [
          IconButton(
              icon: Icon(FontAwesome.qrcode,
                  color: Theme.of(context).primaryColor),
              onPressed: () => scanQR())
        ],
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
    if(barcodeScanRes != "-1"){
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
            labelColor: Theme.of(context).primaryColor,
            isScrollable: false,
            labelPadding: EdgeInsets.only(right: 45.0),
            unselectedLabelColor: Color(0xFFCDCDCD),
            tabs: [
              Tab(
                child: Text('Bags',
                    style: TextStyle(
                      fontSize: 18.0,
                    )),
              ),
              Tab(
                child: Text('Shoes',
                    style: TextStyle(
                      fontSize: 18.0,
                    )),
              ),
              Tab(
                child: Text('Shirts',
                    style: TextStyle(
                      fontSize: 18.0,
                    )),
              )
            ]),
        Container(
            height: MediaQuery.of(context).size.height / 2.3,
            width: double.infinity,
            child: TabBarView(controller: _tabController, children: [
              BagScreen(),
              BagScreen(),
              BagScreen(),
            ])),
        SizedBox(height: 15.0),
      ],
    );
  }
}
