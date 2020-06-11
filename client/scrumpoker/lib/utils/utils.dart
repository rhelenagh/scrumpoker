import 'package:flutter/material.dart';
import 'package:scrumpoker/model/member_and_vote.dart';
import 'package:scrumpoker/utils/constants.dart';
import 'package:t_stats/t_stats.dart';

/// Utils
///
/// General class for the extra handling of Widgets and functions.
///
class Utils {
// fit text to dimensions
  static Widget adjustText(String text, [TextStyle style]) => FittedBox(
        fit: BoxFit.fitWidth,
        alignment: AlignmentDirectional.centerStart,
        child: Text(text, style: style),
      );

// Show background image
  static Widget backgroundImage(double height, double width) => Positioned(
      top: 0,
      left: 0.0,
      right: 0.0,
      child: Image.asset(
        Constants.imageBackground,
        fit: BoxFit.cover,
        height: height,
        width: width,
      ));

// this method can be implemented in another class
  static int getMeanOfVotes(List<MemberAndVote> _list) {
    if (_list.length >= 0) {
      // Get the mean of the members vote list
      final onlyVotes = _list.map((e) => e.vote).toList();
      final stats = Statistic.from(onlyVotes);
      return stats.median.toInt();
      // return (onlyVotes.reduce((a,b) => a + b) / onlyVotes.length).ceil();
    } else {
      return 0;
    }
  }
}
