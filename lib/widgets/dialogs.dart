import 'package:annaistore/models/product.dart';
import 'package:annaistore/utils/universal_variables.dart';
import 'package:flutter/material.dart';

enum DialogAction { yes, Abort }

class Dialogs {
  static Future<DialogAction> yesAbortDialog(BuildContext context, String title,
      String body, GestureTapCallback yesOnTap) async {
    final action = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text(title),
            content: Text(body),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(DialogAction.Abort);
                },
                child: Text(
                  "No",
                  style: TextStyle(color: Variables.primaryColor),
                ),
              ),
              RaisedButton(
                elevation: 0,
                color: Variables.primaryColor,
                onPressed: yesOnTap,
                child: Text(
                  "Yes",
                  style: TextStyle(color: Variables.lightGreyColor),
                ),
              )
            ],
          );
        });
    return (action != null) ? action : DialogAction.Abort;
  }

  static Future<DialogAction> textFieldDialog(BuildContext context,
      String title, GestureTapCallback yesOnTap, Product currentProduct) async {
    TextEditingController bulkQtyController = TextEditingController();

    final action = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text(title),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Quantity",
                  style: Variables.inputLabelTextStyle,
                ),
                Container(
                  height: 48,
                  width: 100,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(8)),
                  child: TextFormField(
                    cursorColor: Variables.primaryColor,
                    validator: (value) {
                      if (value.isEmpty)
                        return "You cannot have an empty Quantity!";
                      if (value.length != 6) return "Enter valid pincode!";
                    },
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    style: Variables.inputTextStyle,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Quantity'),
                    controller: bulkQtyController,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(DialogAction.Abort);
                },
                child: Text(
                  "No",
                  style: TextStyle(color: Variables.primaryColor),
                ),
              ),
              RaisedButton(
                elevation: 0,
                color: Variables.primaryColor,
                onPressed: yesOnTap,
                child: Text(
                  "Yes",
                  style: TextStyle(color: Variables.lightGreyColor),
                ),
              )
            ],
          );
        });
    return (action != null) ? action : DialogAction.Abort;
  }

  static Future<DialogAction> okDialog(
      BuildContext context, String title, String body, Color titleColor) async {
    final action = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text(
              title,
              style: TextStyle(color: titleColor),
            ),
            content: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Text(
                body,
                style: TextStyle(color: Variables.blackColor),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(DialogAction.Abort);
                },
                child: Text(
                  "Ok",
                  style: TextStyle(color: titleColor),
                ),
              ),
            ],
          );
        });

    return (action != null) ? action : DialogAction.Abort;
  }
}
