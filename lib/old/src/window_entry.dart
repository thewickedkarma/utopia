// ignore_for_file: constant_identifier_names

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:utopia_wm/old/src/window_toolbar.dart';
import 'package:utopia_wm/wm.dart';

class WindowEntry extends ChangeNotifier {
  final WindowEntryId id;
  String? _title;
  ImageProvider? _icon;
  final Widget content;
  bool _usesToolbar;
  Color _toolbarColor;
  final String packageName;
  final Size initialSize;
  final bool initiallyCenter;
  final Size minSize;
  late Rect _windowRect;
  Widget? _toolbar;
  bool _maximized = false;
  bool _minimized = false;
  WindowDock _windowDock = WindowDock.NORMAL;
  final Color bgColor;
  final double elevation;
  final bool allowResize;
  final ShapeBorder _shape;

  final GlobalKey repaintBoundaryKey = GlobalKey();

  String? get title => _title;
  ImageProvider? get icon => _icon;
  bool get usesToolbar => _usesToolbar;
  Color get toolbarColor => _toolbarColor;
  Rect get windowRect => _windowRect;
  Widget? get toolbar => _toolbar;
  bool get maximized => _maximized;
  bool get minimized => _minimized;
  WindowDock get windowDock => _windowDock;
  ShapeBorder get shape => _shape;

  set title(String? value) {
    _title = value;
    notifyListeners();
  }

  set icon(ImageProvider? value) {
    _icon = value;
    notifyListeners();
  }

  set usesToolbar(bool value) {
    _usesToolbar = value;
    notifyListeners();
  }

  set toolbarColor(Color value) {
    _toolbarColor = value;
    notifyListeners();
  }

  set windowRect(Rect value) {
    _windowRect = value;
    notifyListeners();
  }

  set toolbar(Widget? value) {
    _toolbar = value;
    notifyListeners();
  }

  set maximized(bool value) {
    _maximized = value;
    notifyListeners();
  }

  set minimized(bool value) {
    _minimized = value;
    notifyListeners();
  }

  set windowDock(WindowDock value) {
    _windowDock = value;
    notifyListeners();
  }

  WindowEntry({
    required this.packageName,
    String? title,
    ImageProvider? icon,
    required this.content,
    bool usesToolbar = false,
    Color toolbarColor = const Color(0xFF212121),
    Widget? toolbar,
    this.initialSize = const Size(600, 480),
    this.initiallyCenter = false,
    this.minSize = const Size.square(100),
    ShapeBorder shape = const RoundedRectangleBorder(),
    this.bgColor = Colors.transparent,
    this.elevation = 4,
    this.allowResize = false,
  })  : id = WindowEntryId(),
        _title = title,
        _icon = icon,
        _usesToolbar = usesToolbar,
        _toolbarColor = toolbarColor,
        _toolbar = toolbar,
        _shape = shape;

  WindowEntry.withDefaultToolbar({
    required this.packageName,
    String? title,
    ImageProvider? icon,
    required this.content,
    Color toolbarColor = const Color(0xFF212121),
    this.initialSize = const Size(600, 480),
    this.initiallyCenter = true,
    this.minSize = const Size(360, 240),
    ShapeBorder? shape,
    this.bgColor = Colors.transparent,
    this.elevation = 4,
    this.allowResize = true,
  })  : id = WindowEntryId(),
        _title = title,
        _toolbarColor = toolbarColor,
        _icon = icon,
        _shape = shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
        _usesToolbar = true,
        _toolbar = const DefaultWindowToolbar();

  void toggleMaximize() {
    maximized = !maximized;
  }

  Future<Uint8List> getScreenshot() async {
    final box = repaintBoundaryKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
    final image = await box.toImage();
    final byteData = await image.toByteData(
      format: ImageByteFormat.png,
    );

    return byteData!.buffer.asUint8List();
  }
}

class WindowEntryId {
  int compareTo(WindowEntryId other) {
    return hashCode.compareTo(other.hashCode);
  }

  @override
  String toString() => hashCode.toString();
}

enum WindowDock {
  NORMAL,
  TOP_LEFT,
  TOP,
  TOP_RIGHT,
  RIGHT,
  LEFT,
  BOTTOM_LEFT,
  BOTTOM,
  BOTTOM_RIGHT,
}
