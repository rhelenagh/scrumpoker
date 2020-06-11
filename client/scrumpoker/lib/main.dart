import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scrumpoker/api/poker_communication.dart';

import 'package:scrumpoker/model/member.dart';
import 'package:scrumpoker/model/member_and_vote.dart';

import 'package:scrumpoker/model/poker_message.dart';
import 'package:scrumpoker/model/session.dart';

import 'package:scrumpoker/routes/route_generator.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:scrumpoker/ui/members_list.dart';
import 'package:scrumpoker/ui/show_members_cards.dart';
import 'package:scrumpoker/utils/utils.dart';
import 'package:enum_to_string/enum_to_string.dart';

import 'dart:html' as html;

import 'package:scrumpoker/di.dart' as di;

enum SessionStatus { None, Open, Voting, Closed }

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the configuration file
  await DotEnv().load('.env');

  // Load the DI
  di.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrum Poker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final inputController = TextEditingController();
  final joinTextController = TextEditingController();
  List<String> memberList = [];
  List<MemberAndVote> _memberAndVoteList = [];
  final _pokerCommunication = di.getIt<PokerCommunication>();

  Session _actualSession;
  String _sessionName;
  String _sessionId = '';
  bool _turnedCards = true;
  int _meanOfVotes = 0;
  List<String> _sessionState = List()
    ..add("Open")
    ..add("Voting")
    ..add("Closed");

  SessionStatus _sessionStatus = SessionStatus.None;

  List<bool> _selectionsState = List.generate(3, (_) => false);

  _MyHomePageState() {
    // Register the PokerComunication stream
    _pokerCommunication.channel.stream.listen((data) {
      _handleResponseData(data);
    });
  }

  void sendToServer(String msg) {
    _pokerCommunication.channel.sink.add(msg);
  }

  @override
  void dispose() {
    inputController.dispose();
    joinTextController.dispose();
    _pokerCommunication.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Material(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // background image
          Utils.backgroundImage(size.height, size.width),

          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Session container
                  Container(
                    width: size.width * 0.49,
                    height: size.height * 0.39,
                    child: _sessionContainer(),
                  ),

                  // Members list
                  MembersList(memberList: memberList),
                ],
              ),

              // Members cards
              Visibility(
                  visible: _memberAndVoteList.length > 0,
                  child: Flexible(
                      fit: FlexFit.loose,
                      child: ShowMembersCards(
                          memberAndVoteList: _memberAndVoteList,
                          turnedCards: _turnedCards))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sessionContainer() {
    final _path = "join";
    var joinUri = "${html.window.location.href}$_path?id=$_sessionId";

    joinTextController.text =
        "To join the session, go to this address:  $joinUri";

    final _sessionLocation =
        '${html.window.location.href}$_path?id=$_sessionId';

    var size = MediaQuery.of(context).size;
    final TextStyle display1 = Theme.of(context).textTheme.headline5;
    return Card(
      elevation: 5,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Utils.adjustText("Welcome to the Scrum poker",
                  GoogleFonts.oxygen(textStyle: display1)),
            ),

            // Session Input Widget
            _sessionInputName(size),

            SizedBox(height: 5),
            Visibility(
                visible: _sessionId.isNotEmpty,
                child: Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Utils.adjustText(
                          "The session was created successfully. ✌",
                          TextStyle(fontSize: 16)),
                      SizedBox(height: 5),
                      _moreSessionInfo(_sessionLocation),

                      SizedBox(height: 5),
                      Text(
                          "The Session is: ${EnumToString.parse(_sessionStatus)}"),
                      SizedBox(height: 2),

                      // Session Actions
                      _sessionActions(),

                      // Mean result
                      _meanResult(),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _sessionInputName(Size size) => Padding(
        padding: EdgeInsets.all(14.0),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: size.width / 7,
                height: 40,
                child: TextField(
                  controller: inputController,
                  autofocus: true,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: 'Session name',
                    border: OutlineInputBorder(),
                  ),
                  style: GoogleFonts.lato(fontStyle: FontStyle.italic),
                ),
              ),
              SizedBox(width: 10),
              Visibility(
                visible: _sessionStatus == SessionStatus.None ||
                    _sessionStatus == SessionStatus.Closed,
                child: RaisedButton(
                  child: Text(
                    'Create',
                    style: GoogleFonts.lato(),
                  ),
                  onPressed: () {
                    if (inputController.text.isNotEmpty) {
                      _createSession(inputController.text);
                      setState(() {
                        _sessionName = inputController.text;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );

  Widget _moreSessionInfo(String _sessionLocation) => Padding(
        padding: const EdgeInsets.all(6.0),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                  text: TextSpan(
                      text: 'To join the session, go to this address: ',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      children: <TextSpan>[
                    TextSpan(
                      text: _sessionLocation,
                      style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                    )
                  ])),
              IconButton(
                  icon: Icon(Icons.content_copy),
                  tooltip: 'Copy link',
                  onPressed: () {
                    Clipboard.setData(
                        new ClipboardData(text: _sessionLocation));
                  })
            ],
          ),
        ),
      );

  Widget _sessionActions() => Flexible(
        fit: FlexFit.loose,
        flex: 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Session status
            // TODO assign the correct icons

            ToggleButtons(
              children: <Widget>[
                Icon(
                  Icons.lock_open,
                  semanticLabel: "Session Open",
                ),
                Icon(Icons.chrome_reader_mode),
                Icon(Icons.lock_outline),
              ],
              onPressed: (int index) {
                setState(() {
                  _selectionsState[index] = !_selectionsState[index];
                  _updateSessionStatus(_sessionState[index]);
                  //
                  _sessionStatus = SessionStatus.values[index + 1];
                });
              },
              isSelected: _selectionsState,
            ),
            SizedBox(width: 10),
            IconButton(
                icon: Icon(Icons.flip),
                tooltip: 'flip cards',
                onPressed: () {
                  setState(() {
                    _meanOfVotes = Utils.getMeanOfVotes(_memberAndVoteList);
                    _turnedCards = false;
                  });
                })
          ],
        ),
      );

  Widget _meanResult() => Visibility(
        visible: _meanOfVotes > 0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Utils.adjustText('The mean vote of the cards is: ',
                TextStyle(fontSize: 16, color: Colors.white)),
            SizedBox(width: 5),
            CircleAvatar(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                radius: 20,
                child: Utils.adjustText(
                  "$_meanOfVotes",
                  TextStyle(fontSize: 16),
                )),
          ],
        ),
      );

  /// methods session
  ///

  _handleResponseData(dynamic data) {
    var dataDecode = json.decode(data);
    var type = dataDecode["type"] as String;

    switch (type) {
      case 'session':
        _sessionCreated(data);
        break;

      case 'newMember':
        Member parseMember = Member.fromJson(data);
        _addMemberToList(parseMember.memberName);
        break;

      case 'memberVote':
        _memberVote(data);
        break;

      default:
    }
  }

  _createSession(String sessionname) {
    setState(() {
      Session _session = Session(
        sessionName: sessionname,
      );

      // create the action of type create plus session name
      PockerMessage _action = PockerMessage('create', _session.toJson());

      // Send to the server
      sendToServer(_action.toJson());
    });
  }

  _updateSessionStatus(String status) {
    setState(() {
      Session _tempSession = Session(
          id: _actualSession.id, sessionName: _sessionName, status: status);
      PockerMessage _action =
          PockerMessage('update_session', _tempSession.toJson());
      // Send to the server
      sendToServer(_action.toJson());
    });
  }

  _addMemberToList(memberName) {
    final _memberfound =
        memberList.firstWhere((m) => m == memberName, orElse: () => '');
    if (_memberfound.isEmpty) {
      setState(() => memberList.add(memberName));
    }
  }

  void _sessionCreated(data) {
    Session parseSession = Session.fromJson(data);
    setState(() {
      _actualSession = parseSession;
      _sessionId = parseSession.id;
      _selectionsState[0] = true;
      _sessionStatus = SessionStatus.Open;
    });
  }

  void _memberVote(data) {
    MemberAndVote parseMember = MemberAndVote.fromJson(data);
    setState(() {
      if (_sessionStatus != SessionStatus.Voting) {
        _sessionStatus = SessionStatus.Voting;
        // activate the ToggleButtons
        _selectionsState[1] = true;
      }
      _memberAndVoteList.add(parseMember);
      _memberAndVoteList.sort((a, b) => a.memberName.compareTo(b.memberName));
    });
  }
}
