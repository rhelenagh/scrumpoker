import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrumpoker/utils/utils.dart';

class MembersList extends StatelessWidget {
  final List<String> memberList;

  const MembersList({Key key, this.memberList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final TextStyle display1 = Theme.of(context).textTheme.headline5;

    return Container(
      width: size.width * 0.29,
      height: size.height * 0.39,
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Utils.adjustText("Players for the session",
                        GoogleFonts.oxygen(textStyle: display1)),
                    SizedBox(width: 10),
                    Visibility(
                      visible: memberList.length > 0,
                      child: CircleAvatar(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          radius: 18,
                          child: Utils.adjustText(
                            "${memberList.length}",
                            TextStyle(fontSize: 14),
                          )),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 5,
            ),
            Flexible(
              fit: FlexFit.loose,
              child: Container(child: getMembersList()),
            ),
          ],
        ),
      ),
    );
  }

  ListView getMembersList() {
    List<Widget> listWidget = [];

// Sort the list
    memberList.sort((a, b) => a.compareTo(b));
    for (String member in memberList) {
      listWidget.add(ListTile(
        leading: CircleAvatar(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            radius: 18,
            child: Text(
              member.substring(0, 1).toUpperCase(),
              style: TextStyle(fontSize: 14),
            )),
        title: Text(member, style: TextStyle(fontSize: 14)),
      ));
    }

    return ListView(children: listWidget);
  }
}
