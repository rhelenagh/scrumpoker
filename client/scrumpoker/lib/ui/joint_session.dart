import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrumpoker/api/poker_communication.dart';
import 'package:scrumpoker/utils/constants.dart';

import 'package:scrumpoker/model/member.dart';
import 'package:scrumpoker/model/poker_message.dart';
import 'package:scrumpoker/utils/draggable_view.dart';
import 'package:scrumpoker/utils/utils.dart';
import 'package:scrumpoker/di.dart' as di;

class JoinSession extends StatefulWidget {
  final String sessionid;

  JoinSession({
    Key key,
    this.sessionid,
  }) : super(key: key);

  @override
  _JoinSessionState createState() => _JoinSessionState(sessionid: sessionid);
}

class _JoinSessionState extends State<JoinSession> {
  final String sessionid;
  Size itemSize;
  final joinTextController = TextEditingController();
  final _pokerCommunication = di.getIt<PokerCommunication>();

  bool _memberJoined = false;
  bool _cardSent = false;

  String _memberName;
  String _selectedCard = '';
  int _selectedCardIndex = -1;

  static const String _ErrorSession_NotFound = "The session you want to join was not found. 😕\nContact the Scrum Master";
  static const String _ErrorSession_Closed = "The session you wish to join is currently closed. 😟\nContact the Scrum master";


  _JoinSessionState({this.sessionid}) {
    // Register the PokerComunication stream
    _pokerCommunication.channel.stream.listen((data) {
      _handleResponseData(data);
    });
  }

  _handleResponseData(dynamic data) {
    var dataDecode = json.decode(data);
    var type = dataDecode["type"] as String;

    switch (type) {
      case 'newMember':
        setState(() => _memberJoined = true);
        break;

      case 'sessionClosed':
        _showClosedSessionDialog(_ErrorSession_Closed);
        break;

      case 'sessionNotFound':
        _showClosedSessionDialog(_ErrorSession_NotFound);
        break;  

      default:
    }
  }

  void sendToServer(String msg) {
    _pokerCommunication.channel.sink.add(msg);
  }

  @override
  void dispose() {
    _pokerCommunication.dispose();
    joinTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        title: Utils.adjustText("Join to session $sessionid"),
      ),
      body: _joinForm(context),
    );
  }

  Widget _joinForm(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Utils.adjustText("Join to Session"),
          SizedBox(height: 30),
          Container(
            width: size.width / 6,
            height: 40,
            child: TextField(
              controller: joinTextController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Your name',
                border: OutlineInputBorder(),
              ),
              style: GoogleFonts.lato(fontStyle: FontStyle.italic),
            ),
          ),
          SizedBox(height: 15),
          Visibility(
            visible: !_memberJoined,
            child: RaisedButton(
                child: Text(
                  'Join',
                  style: GoogleFonts.lato(),
                ),
                onPressed: () async {
                  if (joinTextController.text.isNotEmpty) {
                    _joinSession(joinTextController.text.trim());
                    _memberName = joinTextController.text.trim();
                  }
                }),
          ),
          SizedBox(height: 10),
          Visibility(
              visible: _memberJoined,
              child: Expanded(child: _showCards(context))),
          SizedBox(height: 10),
          Visibility(
              visible: _memberJoined,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Utils.adjustText(
                      "Card to play", GoogleFonts.lato(fontSize: 16)),
                  SizedBox(width: 20),
                  Visibility(
                    visible: _selectedCard.isNotEmpty && !_cardSent,
                    child: RaisedButton(
                        child: Text(
                          'Send card',
                          style: GoogleFonts.lato(),
                        ),
                        onPressed: () async => _sendCard()),
                  ),
                ],
              )),
          SizedBox(height: 10),
          Visibility(visible: _memberJoined, child: _dragTarget(context)),
        ],
      ),
    );
  }

  _joinSession(String name) {
    var _member = Member(sessionId: sessionid, memberName: name, vote: 0);
    // create the action of type create plus session name
    PockerMessage _action = PockerMessage('joined', _member.toJson());
    // Send to the server
    sendToServer(_action.toJson());
  }

  _sendCard() {
    var _member = Member(
        sessionId: sessionid,
        memberName: _memberName,
        vote: Constants.cardList[_selectedCardIndex]);
    // create the action of type create plus session name
    PockerMessage _action = PockerMessage('vote', _member.toJson());
    // Send to the server
    sendToServer(_action.toJson());
    setState(() => _cardSent = true);
  }

  Widget _showCards(BuildContext context) => Container(
        width: 600,
        height: 400,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 14,
              ),
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                itemSize = MediaQuery.of(context).size / 4;

                final _nameCard =
                    'assets/images/${Constants.cardList[index]}.png';

                return Padding(
                  padding: EdgeInsets.all(4),
                  child: Draggable(
                    dragAnchor: DragAnchor.pointer,
                    feedback: getCenteredAvatar(_nameCard),
                    child: Image.asset(_nameCard),
                    onDragStarted: () => {
                      if (!_cardSent)
                        {
                          setState(() {
                            _selectedCard = '';
                            _selectedCardIndex = -1;
                          })
                        }
                    },
                    onDragCompleted: () => {
                      setState(() {
                        _selectedCard = _nameCard;
                        // set the index of the card to the select card property
                        _selectedCardIndex = index;
                      })
                    },
                  ),
                );
              }, childCount: Constants.cardList.length),
            ),
          ],
        ),
      );

  Widget getCenteredAvatar(String card) => new Transform(
      transform: new Matrix4.identity()
        ..translate(-100.0 / 2.0, -(100.0 / 2.0)),
      child: DragAvatarBorder(
        Image.asset(card),
        size: itemSize,
        color: Colors.transparent,
      ));

  Widget _dragTarget(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return DragTarget(
      builder: (context, accepted, rejected) {
        return Container(
            width: size.width / 4,
            height: size.height / 4,
            decoration: BoxDecoration(color: Colors.green[200]),
            child: _selectedCard.isEmpty
                ? Utils.adjustText("Drop the card here 💁")
                : Visibility(
                    visible: _selectedCard.isNotEmpty,
                    child: Image.asset(_selectedCard)));
      },
    );
  }

  void _showClosedSessionDialog(String msg) => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text("Session failed"),
            content: Text(msg),
            actions: [
              FlatButton(
                  child: Text("Close"),
                  onPressed: () => Navigator.of(context).pop()),
            ],
          ));
}
