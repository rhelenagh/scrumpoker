import 'dart:convert';

import 'package:scrumpoker/model/member_and_vote.dart';

/// Session class
/// 
/// Class that represents the content of the session. (In Scrum it could represent a task or story)
class Session {
  final String id;
  final String sessionName;
  final String status;
  final List<MemberAndVote> members;
  
  

  Session({
    this.id,
    this.sessionName,
    this.status,
    this.members,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionName': sessionName,
      'status': status,
      'members': members?.map((x) => x?.toMap())?.toList(),
    };
  }

  static Session fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    var _memberandVote = map['members'];
  
    return Session(
      id: map['id'],
      sessionName: map['sessionName'],
      status: map['status'],
      members:  _memberandVote != null ? List<MemberAndVote>.from(map['members']?.map((x) => MemberAndVote.fromMap(x))) : List<MemberAndVote>(),
    );
  }

  String toJson() => json.encode(toMap());

  static Session fromJson(String source) => fromMap(json.decode(source));
  

  Session copyWith({
    String id,
    String sessionName,
    String status,
    List<MemberAndVote> members,
  }) {
    return Session(
      id: id ?? this.id,
      sessionName: sessionName ?? this.sessionName,
      status: status ?? this.status,
      members: members ?? this.members,
    );
  }
  
}
