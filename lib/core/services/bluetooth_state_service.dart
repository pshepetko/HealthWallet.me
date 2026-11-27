import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class BluetoothStateService {
  static const _methodChannel =
      MethodChannel('com.healthwithme.app/bluetooth');
  static const _eventChannel =
      EventChannel('com.healthwithme.app/bluetooth_state');

  StreamSubscription<dynamic>? _subscription;
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onStateChanged => _controller.stream;

  void startListening() {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    _subscription ??= _eventChannel.receiveBroadcastStream().listen((event) {
      _controller.add(event as bool);
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<bool> isEnabled() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return true;
    try {
      final result =
          await _methodChannel.invokeMethod<bool>('isBluetoothEnabled');
      return result ?? false;
    } catch (_) {
      return true;
    }
  }

  Future<void> requestEnable() async {
    try {
      await _methodChannel.invokeMethod('requestEnable');
    } catch (_) {}
  }

  @disposeMethod
  void dispose() {
    stopListening();
    _controller.close();
  }
}
