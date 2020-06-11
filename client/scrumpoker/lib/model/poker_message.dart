import 'dart:convert';

/// PockerMessage class
/// 
/// This class is used as a transport to send information to the WebSocket server.
/// It has two properties: a type and a data.
/// The server is capable of decoding this information and executing the necessary functions.
class PockerMessage {
  final String type;
  final String data;

  PockerMessage(this.type, this.data);
   

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'data': data,
    };
  }

  static PockerMessage fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return PockerMessage(
      map['type'],
      map['data'],
    );
  }

  String toJson() => json.encode(toMap());

  static PockerMessage fromJson(String source) => fromMap(json.decode(source));
}
