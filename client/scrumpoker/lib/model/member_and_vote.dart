import 'dart:convert';

/// MemberAndVote class
/// 
/// Class that represents a member's vote against a task or story.
class MemberAndVote {
  final String memberName;
  final int vote;

  MemberAndVote({
    this.memberName,
    this.vote,
  });



  Map<String, dynamic> toMap() {
    return {
      'memberName': memberName,
      'vote': vote,
    };
  }

  static MemberAndVote fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return MemberAndVote(
      memberName: map['memberName'],
      vote: map['vote'],
    );
  }

  String toJson() => json.encode(toMap());

  static MemberAndVote fromJson(String source) => fromMap(json.decode(source));
}
