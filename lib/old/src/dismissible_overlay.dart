import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/old/src/dismissible_overlay_entry.dart';
import 'package:utopia_wm/old/src/window_hierarchy.dart';

class DismissibleOverlay extends StatefulWidget {
  final DismissibleOverlayEntry entry;

  const DismissibleOverlay({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  _DismissibleOverlayState createState() => _DismissibleOverlayState();
}

class _DismissibleOverlayState extends State<DismissibleOverlay>
    with SingleTickerProviderStateMixin {
  static final _childKey = GlobalKey();
  final _focusNode = FocusNode(canRequestFocus: true);

  @override
  void initState() {
    widget.entry.animationController = AnimationController(
      vsync: this,
      duration: widget.entry.duration,
    );
    widget.entry.animation = CurvedAnimation(
      curve: widget.entry.curve,
      reverseCurve: widget.entry.reverseCurve,
      parent: widget.entry.animationController,
    );
    widget.entry.animationController.animateTo(1);
    _focusNode.requestFocus();

    super.initState();
  }

  @override
  void dispose() {
    widget.entry.animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DismissibleOverlayEntry>.value(
      value: widget.entry,
      builder: (context, _) {
        final entry = context.watch<DismissibleOverlayEntry>();
        final child = KeyedSubtree(
          child: entry.content,
          key: _childKey,
        );

        return RawKeyboardListener(
          focusNode: _focusNode,
          onKey: (event) {
            if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
              _dismissOverlay();
            }
          },
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) {
              final RenderBox box =
                  _childKey.currentContext!.findRenderObject() as RenderBox;

              final position = box.localToGlobal(Offset.zero);
              final rect = position & box.size;
              final hitTested =
                  box.hitTest(BoxHitTestResult(), position: event.position);
              final pointInsideRect = rect.contains(event.position);

              if (hitTested) return;
              if (pointInsideRect) return;
              _dismissOverlay();
            },
            child: Stack(
              children: [
                IgnorePointer(
                  child: SizedBox.expand(
                    child: entry.background ??
                        Container(color: Colors.transparent),
                  ),
                ),
                child,
              ],
            ),
          ),
        );
      },
    );
  }

  void _dismissOverlay() async {
    final _hierarchy = context.read<WindowHierarchyState>();

    await widget.entry.animationController.reverse();
    _hierarchy.popOverlayEntry(widget.entry);
    setState(() {});
  }
}
