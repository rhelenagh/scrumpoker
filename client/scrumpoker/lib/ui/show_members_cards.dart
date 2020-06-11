import 'package:flutter/material.dart';
import 'package:scrumpoker/model/member_and_vote.dart';
import 'package:scrumpoker/ui/member_card_item.dart';

class ShowMembersCards extends StatefulWidget {
  final List<MemberAndVote> memberAndVoteList;
  final bool turnedCards;

  const ShowMembersCards(
      {Key key, @required this.memberAndVoteList, @required this.turnedCards})
      : super(key: key);

  @override
  _ShowMembersCardsState createState() => new _ShowMembersCardsState();
}

class _ShowMembersCardsState extends State<ShowMembersCards> {
  @override
  Widget build(BuildContext context) => Container(
        width: 900,
        height: 1000,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                MemberAndVote item = widget.memberAndVoteList[index];

                return Padding(
                  padding: EdgeInsets.all(4),
                  child: MemberCardItem(item: item, turned: widget.turnedCards),
                );
              }, childCount: widget.memberAndVoteList.length),
            ),
          ],
        ),
      );
}
