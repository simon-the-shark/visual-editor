import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../controller/state/scroll-controller.state.dart';
import '../../editor/services/editor-renderer.utils.dart';
import '../../editor/widgets/editor-renderer.dart';

class CursorService {
  static final _scrollControllerState = ScrollControllerState();
  static final _editorRendererUtils = EditorRendererUtils();
  static final _instance = CursorService._privateConstructor();

  factory CursorService() => _instance;

  CursorService._privateConstructor();

  void bringIntoView(TextPosition position, EditorRenderer renderer) {
    final localRect = getLocalRectForCaret(position, renderer);
    final targetOffset = _getOffsetToRevealCaret(localRect, position, renderer);

    if (_scrollControllerState.controller.hasClients) {
      _scrollControllerState.controller.jumpTo(targetOffset.offset);
    }

    renderer.showOnScreen(
      rect: targetOffset.rect,
    );
  }

  Rect getLocalRectForCaret(TextPosition position, EditorRenderer renderer) {
    final targetChild = _editorRendererUtils.childAtPosition(
      position,
      renderer,
    );
    final localPosition = targetChild.globalToLocalPosition(position);
    final childLocalRect = targetChild.getLocalRectForCaret(localPosition);
    final boxParentData = targetChild.parentData as BoxParentData;

    return childLocalRect.shift(Offset(0, boxParentData.offset.dy));
  }

  // Finds the closest scroll offset to the current scroll offset that fully reveals the given caret rect.
  // If the given rect's main axis extent is too large to be fully revealed in `renderEditable`,
  // it will be centered along the main axis.
  //
  // If this is a multiline VisualEditor (which means the Editable can only  scroll vertically),
  // the given rect's height will first be extended to match `renderEditable.preferredLineHeight`,
  // before the target scroll offset is calculated.
  RevealedOffset _getOffsetToRevealCaret(
    Rect rect,
    TextPosition position,
    EditorRenderer renderer,
  ) {
    if (_isConnectedAndAllowedToSelfScroll()) {
      return RevealedOffset(
        offset: _scrollControllerState.controller.offset,
        rect: rect,
      );
    }

    // +++ EXTRACT
    final editableSize = renderer.size;
    final double additionalOffset;
    final Offset unitOffset;

    // The caret is vertically centered within the line. Expand the caret's
    // height so that it spans the line because we're going to ensure that the entire expanded caret is scrolled into view.
    final expandedRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width,
      height: math.max(
        rect.height,
        _editorRendererUtils.preferredLineHeight(position, renderer),
      ),
    );

    additionalOffset = expandedRect.height >= editableSize.height
        ? editableSize.height / 2 - expandedRect.center.dy
        : 0.0.clamp(
            expandedRect.bottom - editableSize.height,
            expandedRect.top,
          );

    unitOffset = const Offset(0, 1);

    // No overscrolling when encountering tall fonts/scripts that extend past the ascent.
    var targetOffset = additionalOffset;

    if (_scrollControllerState.controller.hasClients) {
      targetOffset =
          (additionalOffset + _scrollControllerState.controller.offset).clamp(
        _scrollControllerState.controller.position.minScrollExtent,
        _scrollControllerState.controller.position.maxScrollExtent,
      );
    }

    final offsetDelta = (_scrollControllerState.controller.hasClients
            ? _scrollControllerState.controller.offset
            : 0) -
        targetOffset;

    return RevealedOffset(
      rect: rect.shift(unitOffset * offsetDelta),
      offset: targetOffset,
    );
  }

  bool _isConnectedAndAllowedToSelfScroll() {
    return _scrollControllerState.controller.hasClients &&
      !_scrollControllerState.controller.position.allowImplicitScrolling;
  }
}
