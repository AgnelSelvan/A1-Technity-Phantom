import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/custom_appbar.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textFieldController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          bgColor: Colors.white,
          title: Text("Stock Q", style: Variables.appBarTextStyle),
          actions: null,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Ionicons.ios_arrow_back,
              color: Variables.primaryColor,
            ),
          ),
          centerTitle: true),
      body: Column(
        children: <Widget>[
          Flexible(
            child: messageList(),
          ),
          Spacer(),
          chatControls(),
        ],
      ),
    );
  }

  Widget messageList() {
    // return StreamBuilder(
    //   // stream: ,
    //   builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    //     if (snapshot.data == null) {
    //       return Center(child: CustomCircularLoading());
    //     }

    //     return Stack(children: <Widget>[
    //       ListView.builder(
    //         padding: EdgeInsets.only(right: 5),
    //         controller: _listScrollController,
    //         reverse: true,
    //         itemCount: snapshot.data.documents.length,
    //         itemBuilder: (context, index) {
    //           // mention the arrow syntax if you get the time
    //           return chatMessageItem(snapshot.data.documents[index]);
    //         },
    //       ),
    //       _isTalking
    //           ? Padding(
    //               padding: const EdgeInsets.only(right: 40.0),
    //               child: Align(
    //                 alignment: Alignment.bottomRight,
    //                 child: FloatingActionButton(
    //                   mini: true,
    //                   backgroundColor: Colors.red,
    //                   onPressed: null,
    //                   child: Icon(
    //                     Icons.stop,
    //                     size: 16,
    //                   ),
    //                 ),
    //               ),
    //             )
    //           : Container(),
    //     ]);
    //   },
    // );
    return Text("Hii");
  }

  Widget chatControls() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: TextField(
              controller: textFieldController,
              focusNode: textFieldFocus,
              onTap: () => null,
              style: TextStyle(
                color: Colors.black,
              ),
              onChanged: (val) {},
              decoration: InputDecoration(
                hintText: "Type a message",
                hintStyle: TextStyle(
                  color: Variables.greyColor,
                ),
                border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(50.0),
                    ),
                    borderSide: BorderSide.none),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                filled: true,
                fillColor: Color(0xffECECEC),
              ),
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                  gradient: Variables.fabGradient, shape: BoxShape.circle),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 15,
                ),
                onPressed: () => null,
              ))
        ],
      ),
    );
  }
}
