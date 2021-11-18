import 'dart:async';

import 'package:stream_channel/isolate_channel.dart';
import 'enum.dart';
import 'isolate_contactor_controller.dart';

class IsolateContactorControllerIpl implements IsolateContactorController {
  late IsolateChannel _delegate;

  final StreamController _mainStreamController = StreamController.broadcast();
  final StreamController _messageStreamController =
      StreamController.broadcast();

  IsolateContactorControllerIpl(dynamic params) {
    if (params is List) {
      _delegate = IsolateChannel.connectSend(params.last);
    } else {
      _delegate = IsolateChannel.connectReceive(params);
    }

    _delegate.stream.listen((event) {
      dynamic message = getRawMessage(IsolatePort.main, event);
      if (message != null) {
        _mainStreamController.add(message);
      }

      message = getRawMessage(IsolatePort.child, event);
      if (message != null) {
        _messageStreamController.add(message);
      }
    });
  }

  @override
  Stream get onMessage => _mainStreamController.stream;

  @override
  Stream get onIsolateMessage => _messageStreamController.stream;

  @override
  void sendIsolate(dynamic message) {
    _delegate.sink.add(<IsolatePort, dynamic>{IsolatePort.child: message});
  }

  @override
  void sendResult(dynamic message) {
    _delegate.sink.add(<IsolatePort, dynamic>{IsolatePort.main: message});
  }
}