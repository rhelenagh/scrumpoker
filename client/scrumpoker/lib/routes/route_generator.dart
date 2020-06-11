import 'package:flutter/material.dart';
import 'package:scrumpoker/main.dart';
import 'package:scrumpoker/extensions/string_extensions.dart';
import 'package:scrumpoker/ui/joint_session.dart';


class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
     // Get the routing Data
     final routingData = settings.name.getRoutingData;
         

    switch (routingData.route) {
      case '/' :
      return MaterialPageRoute(builder: (_) => MyHomePage());
      case '/join' :      
      // Get the session id from the data
      final id = routingData['id'] as String;       
        return MaterialPageRoute(builder: (_) => JoinSession(sessionid: id));             
      default:
       // If there is no such named route in the switch statement
        return _errorRoute('');
    }
  }

  static Route<dynamic> _errorRoute(String errormsg) {
    errormsg = errormsg.isEmpty ? 'Page not Found!' : errormsg;
     return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Text( errormsg ),
        ),
      );
    });
  }

}