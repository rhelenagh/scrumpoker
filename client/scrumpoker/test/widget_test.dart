import 'package:flutter_test/flutter_test.dart';
import 'package:scrumpoker/model/member_and_vote.dart';
import 'package:t_stats/t_stats.dart';

void main() {
  test("meanTest 2", () {
    List<MemberAndVote> _memberandVoteList = []
      ..add(MemberAndVote(memberName: "Test member", vote: 1))
      ..add(MemberAndVote(memberName: "Test member", vote: 2))
      ..add(MemberAndVote(memberName: "Test member", vote: 2))
      ..add(MemberAndVote(memberName: "Test member", vote: 2));

    final onlyVotes = _memberandVoteList.map((e) => e.vote).toList();

    final int mean =
        (onlyVotes.reduce((a, b) => a + b) / onlyVotes.length).ceil();

    expect(mean, equals(2), reason: 'Mean muss be 2');
  });

  test("Median 3", () {
    List<MemberAndVote> _memberandVoteList = []
      ..add(MemberAndVote(memberName: "Test member", vote: 1))
      ..add(MemberAndVote(memberName: "Test member", vote: 21))
      ..add(MemberAndVote(memberName: "Test member", vote: 8))
      ..add(MemberAndVote(memberName: "Test member", vote: 8))
      ..add(MemberAndVote(memberName: "Test member", vote: 3));

    final onlyVotes = _memberandVoteList.map((e) => e.vote).toList();

    final stats = Statistic.from(onlyVotes);

    print(stats);

    final int mean =
        (onlyVotes.reduce((a, b) => a + b) / onlyVotes.length).ceil();

    expect(mean, stats.median, reason: 'Mean muss be 8');
  });
}
