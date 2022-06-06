import 'dart:async';

import '../services/editor-controller.dart';

// Controller object which establishes a link between a rich text document and this editor.
class EditorControllerState {
  factory EditorControllerState() => _instance;
  static final _instance = EditorControllerState._privateConstructor();

  EditorControllerState._privateConstructor();

  final _controller$ = StreamController<EditorController>.broadcast();
  late EditorController _controller;

  Stream<EditorController> get controller$ => _controller$.stream;

  EditorController get controller => _controller;

  void setController(EditorController controller) {
    _controller = controller;
    _controller$.sink.add(controller);
  }
}
