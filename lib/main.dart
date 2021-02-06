import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_q/services/auth.dart';
import 'package:stock_q/services/datastore.dart';
import 'package:stock_q/views/pages/root_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Stock Q',
        debugShowCheckedModeBanner: false,
        theme:
            ThemeData(fontFamily: 'Montserrat', primaryColor: Colors.grey[100]),
        home: RootPage(auth: Auth(), datastore: Datastore()));
  }
}
