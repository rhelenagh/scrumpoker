

import 'package:get_it/get_it.dart';
import 'package:scrumpoker/api/poker_communication.dart';

/// Singleton, Factory  DI method
///
/// Use as 
/// final _pokerCommunication = di.getIt<PokerCommunication>();

final getIt = GetIt.instance;

void init() {
  // PokerCommunication class
  getIt.registerFactory<PokerCommunication>(() => PokerCommunication());
}