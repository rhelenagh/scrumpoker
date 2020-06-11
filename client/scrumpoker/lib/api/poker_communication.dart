
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/html.dart';

/// PokerCommunication class
/// 
/// Class responsible for managing communication through Websockets.
class PokerCommunication {
HtmlWebSocketChannel channel;
static final _webSocketIP = DotEnv().env['WEB_SOCKET_SERVER_IP'] ?? 'ws://localhost:3000/ws';

  PokerCommunication(){
    // Create a new Websocket connection
    channel = HtmlWebSocketChannel.connect(_webSocketIP);
  }

  dispose() {
    if (channel != null)
    channel.sink.close();
  }

}