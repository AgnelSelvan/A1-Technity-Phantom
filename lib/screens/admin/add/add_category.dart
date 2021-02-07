import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:stock_q/models/category.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/screens/custom_loading.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/custom_divider.dart';
import 'package:stock_q/widgets/header.dart';
import 'package:stock_q/widgets/widgets.dart';

final AdminMethods _adminMethods = AdminMethods();

class AddCategory extends StatefulWidget {
  AddCategory({Key key}) : super(key: key);

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  TextEditingController _hsnCodeFieldController = TextEditingController();
  TextEditingController _nameFieldController = TextEditingController();
  TextEditingController _taxFieldController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool viewVisible = false;

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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 5),
              color: Colors.white,
              child: buildSymbolCard(),
            ),
          ],
        ),
      ),
    );
  }

  void showWidget() {
    //print(viewVisible);
    setState(() {
      viewVisible = !viewVisible;
    });
    //print(viewVisible);
  }

  void addCategoryToDb() {
    _adminMethods.isCategoryExists(_hsnCodeFieldController.text).then((value) {
      if (!value) {
        var tax = int.parse(_taxFieldController.text);
        _adminMethods.addCategoryToDb(
            _hsnCodeFieldController.text, _nameFieldController.text, tax);

        final snackbar =
            customSnackBar("Added Successfully", Variables.blackColor);
        _scaffoldKey.currentState.showSnackBar(snackbar);

        setState(() {
          _nameFieldController.clear();
          _hsnCodeFieldController.clear();
          _taxFieldController.clear();
        });
      } else {
        final snackbar = customSnackBar(
            "${_hsnCodeFieldController.text} Already exists!", Colors.red);
        _scaffoldKey.currentState.showSnackBar(snackbar);
      }
    });
  }

  void handleDeleteCategory(String id) {
    _adminMethods.deleteCategory(id);
    final snackbar =
        customSnackBar("Deleted Successfullt!", Variables.blackColor);
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Card buildSymbolCard() {
    return Card(
      elevation: 3,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BuildHeader(
                text: "Category",
              ),
              SizedBox(
                height: 15,
              ),
              buildCategoryTable(),
              viewVisible ? buildVisibility() : Container(),
              Row(
                mainAxisAlignment: viewVisible
                    ? MainAxisAlignment.spaceAround
                    : MainAxisAlignment.center,
                children: <Widget>[
                  buildCustomModelButton(),
                  if (viewVisible) buildSubmissionButton() else Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot> buildCategoryTable() {
    return StreamBuilder(
        stream: _adminMethods.fetchAllCategory(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.docs.length != 0) {
              return Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      buildCategoryHeader(),
                      buildTableBody(),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              );
            } else {
              return Column(
                children: <Widget>[
                  Container(
                    child: Text(
                      "Click Add Category for adding units!",
                      style: TextStyle(
                          color: Variables.blackColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5),
                    ),
                  ),
                  SizedBox(height: 20)
                ],
              );
            }
          }
          return CustomCircularLoading();
        });
  }

  Container buildTableBody() {
    return Container(
      width: double.infinity,
      height: 100,
      child: StreamBuilder(
        stream: _adminMethods.fetchAllCategory(),
        builder: (context, snapshot) {
          var docs = snapshot.data.docs;
          print(docs);
          if (snapshot.hasData) {
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                Category category = Category.fromMap(docs[index].data());
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                        width: 80,
                        child: Text(category.hsnCode,
                            style: TextStyle(
                                fontSize: 16, color: Variables.blackColor))),
                    Container(
                        width: 80,
                        child: Text(category.productName,
                            style: TextStyle(
                                fontSize: 16, color: Variables.blackColor))),
                    Container(
                        width: 80,
                        child: Text(category.tax.toString(),
                            style: TextStyle(
                                fontSize: 16, color: Variables.blackColor))),
                    GestureDetector(
                      onTap: () {
                        handleDeleteCategory(category.id);
                      },
                      child: Container(
                          width: 5,
                          child: Icon(
                            FontAwesome.times_circle,
                            size: 20,
                            color: Colors.red,
                          )),
                    )
                  ],
                );
              },
            );
          }
          return CustomCircularLoading();
        },
      ),
    );
  }

  Row buildCategoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
            width: 80,
            child: Column(
              children: <Widget>[
                Text(
                  'HSN Code',
                  style: TextStyle(fontSize: 16, color: Variables.blackColor),
                ),
                CustomDivider(leftSpacing: 2, rightSpacing: 2)
              ],
            )),
        Container(
            width: 80,
            child: Column(
              children: <Widget>[
                Text(
                  "Name",
                  style: TextStyle(fontSize: 16, color: Variables.blackColor),
                ),
                CustomDivider(leftSpacing: 2, rightSpacing: 2)
              ],
            )),
        Container(
            width: 80,
            child: Column(
              children: <Widget>[
                Text(
                  'Tax',
                  style: TextStyle(fontSize: 16, color: Variables.blackColor),
                ),
                CustomDivider(leftSpacing: 2, rightSpacing: 2)
              ],
            )),
        Container(
          width: 5,
        )
      ],
    );
  }

  GestureDetector buildSubmissionButton() {
    return GestureDetector(
      onTap: addCategoryToDb,
      child: Icon(
        Icons.check_circle,
        size: 30,
        color: Colors.green[200],
      ),
    );
  }

  GestureDetector buildCustomModelButton() {
    return GestureDetector(
      onTap: () {
        showWidget();
      },
      child: Container(
        width: 170,
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(100)),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.yellow[100]),
              child: Icon(
                Icons.add,
                color: Variables.blackColor,
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Text(
              "Add Category",
              style: TextStyle(
                  letterSpacing: 1, fontSize: 16, color: Variables.blackColor),
            )
          ],
        ),
      ),
    );
  }

  Visibility buildVisibility() {
    return Visibility(
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: viewVisible,
        child: Container(
            child: Column(
          children: <Widget>[
            buildHSNCodeField(),
            SizedBox(
              height: 20,
            ),
            buildNameField(),
            SizedBox(
              height: 20,
            ),
            buildTaxField(),
            SizedBox(
              height: 20,
            ),
          ],
        )));
  }

  Widget buildTaxField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            "Tax%",
            style: Variables.inputLabelTextStyle,
          ),
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            cursorColor: Variables.primaryColor,
            validator: (value) {
              if (value.isEmpty) return "You cannot have an empty tax!";
            },
            maxLines: 1,
            style: Variables.inputTextStyle,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '10%'),
            controller: _taxFieldController,
          ),
        ),
      ],
    );
  }

  Widget buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            "Product Name",
            style: Variables.inputLabelTextStyle,
          ),
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            cursorColor: Variables.primaryColor,
            validator: (value) {
              if (value.isEmpty)
                return "You cannot have an empty product name!";
            },
            maxLines: 1,
            style: Variables.inputTextStyle,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: 'Painting Oil'),
            controller: _nameFieldController,
          ),
        ),
      ],
    );
  }

  Widget buildHSNCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            "HSN Code",
            style: Variables.inputLabelTextStyle,
          ),
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            cursorColor: Variables.primaryColor,
            validator: (value) {
              if (value.isEmpty) return "You cannot have an empty code!";
            },
            maxLines: 1,
            style: Variables.inputTextStyle,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '2313'),
            controller: _hsnCodeFieldController,
          ),
        ),
      ],
    );
  }
}
