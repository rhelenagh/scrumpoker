import 'dart:convert';

/// Member class
/// 
/// Class that represents a member of the session.
class Member {
  final String id;
  final String memberName;
  final String sessionId;
  final int vote;

  Member({
    this.id,
    this.memberName,
    this.sessionId,
    this.vote,
  });
  
 

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberName': memberName,
      'sessionId': sessionId,
      'vote': vote,
    };
  }

  static Member fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return Member(
      id: map['id'],
      memberName: map['memberName'],
      sessionId: map['sessionId'],
      vote: map['vote'],
    );
  }

  String toJson() => json.encode(toMap());

  static Member fromJson(String source) => fromMap(json.decode(source));
}
