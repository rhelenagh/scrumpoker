// From https://medium.com/flutter-community/advance-url-navigation-for-flutter-web-d8b5f2d424e6

class RoutingData {
  final String route;
  final Map<String, String> _queryParameters;

  RoutingData({this.route, Map<String, String> queryParameters,}) : _queryParameters = queryParameters;

  operator [] (String key) => _queryParameters[key];

}