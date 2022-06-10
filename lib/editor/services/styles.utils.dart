import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../cursor/models/cursor-style.model.dart';
import '../models/cursor-style-cfg.model.dart';
import '../models/platform-dependent-styles.model.dart';
import '../state/editor-config.state.dart';
import '../state/platform-styles.state.dart';

// Utils used to generate the styles that will be used to render the editor.
class StylesUtils {
  final _editorConfigState = EditorConfigState();
  final _platformStylesState = PlatformStylesState();

  static final _instance = StylesUtils._privateConstructor();

  factory StylesUtils() => _instance;

  StylesUtils._privateConstructor();

  PlatformDependentStylesM getOtherOsStyles(
    TextSelectionThemeData selectionTheme,
    ThemeData theme,
  ) {
    final selectionColor = theme.colorScheme.primary.withOpacity(0.40);

    return PlatformDependentStylesM(
      textSelectionControls: materialTextSelectionControls,
      selectionColor: selectionTheme.selectionColor ?? selectionColor,
      cursorStyle: CursorStyleCfgM(
        cursorColor: selectionTheme.cursorColor ?? theme.colorScheme.primary,
        paintCursorAboveText: false,
        cursorOpacityAnimates: false,
      ),
    );
  }

  PlatformDependentStylesM getAppleOsStyles(
    TextSelectionThemeData selectionTheme,
    BuildContext context,
  ) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final selectionColor = cupertinoTheme.primaryColor.withOpacity(0.40);
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    return PlatformDependentStylesM(
      textSelectionControls: cupertinoTextSelectionControls,
      selectionColor: selectionTheme.selectionColor ?? selectionColor,
      cursorStyle: CursorStyleCfgM(
        cursorColor: selectionTheme.cursorColor ?? cupertinoTheme.primaryColor,
        cursorRadius: const Radius.circular(2),
        cursorOffset: Offset(iOSHorizontalOffset / pixelRatio, 0),
        paintCursorAboveText: true,
        cursorOpacityAnimates: true,
      ),
    );
  }

  CursorStyle cursorStyle() {
    final style = _platformStylesState.styles!.cursorStyle;

    return CursorStyle(
      color: style.cursorColor,
      backgroundColor: Colors.grey,
      width: 2,
      radius: style.cursorRadius,
      offset: style.cursorOffset,
      paintAboveText: _editorConfigState.config.paintCursorAboveText ??
          style.paintCursorAboveText,
      opacityAnimates: style.cursorOpacityAnimates,
    );
  }
}
