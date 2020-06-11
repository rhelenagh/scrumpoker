import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrumpoker/model/member_and_vote.dart';

class MemberCardItem extends StatelessWidget {
  final MemberAndVote item;
  final bool turned;

  const MemberCardItem({@required this.item, @required this.turned});

  @override
  Widget build(BuildContext context) {
    final _nameCard =
        turned ? 'assets/images/joker.png' : 'assets/images/${item.vote}.png';

    final Widget cardImage = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(_nameCard, fit: BoxFit.scaleDown),
    );

    return Material(
        child: GridTile(
      footer: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))),
        clipBehavior: Clip.antiAlias,
        child: GridTileBar(
          backgroundColor: Colors.white24,
          //title: Utils.adjustText(item.memberName, GoogleFonts.lato(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold)),
          title: Center(
              child: Text(item.memberName,
                  style: GoogleFonts.lato(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold))),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: cardImage,
      ),
    ));
  }
}
