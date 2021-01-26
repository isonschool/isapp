import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_math/flutter_math.dart';

class IsonTex extends StatefulWidget {
  final String tex;
  final double screenWidth;
  final SizeChangedCallback onSizeChanged;

  IsonTex(this.tex, this.screenWidth, {this.onSizeChanged})
      : super(key: ValueKey('$tex $screenWidth'));

  @override
  State<StatefulWidget> createState() {
    return _IsonTexState();
  }
}

class _IsonTexState extends State<IsonTex> {
  double textScaleFactor;

  _IsonTexState();

  @override
  void initState() {
    textScaleFactor = 1.0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizeListenableContainer(
          onSizeChanged: widget.onSizeChanged,
          onSizeChangedAdjust: adjustTexIfNeeded(widget.screenWidth),
          child: Math.tex(
            widget.tex,
            textScaleFactor: textScaleFactor,
          ),
        ),
      ],
    );
  }

  SizeChangedCallback adjustTexIfNeeded(double screenWidth) {
    return (Size size) {
      if (textScaleFactor < 1.0) return;
      if (screenWidth - 100.0 < size.width) {
        setState(() {
          textScaleFactor = (screenWidth - 145.0) / size.width;
          print('$screenWidth, $textScaleFactor, ${size.width}');
        });
      }
    };
  }
}

typedef SizeChangedCallback = void Function(Size size);

class SizeListenableContainer extends SingleChildRenderObjectWidget {
  const SizeListenableContainer({
    Key key,
    Widget child,
    this.onSizeChanged,
    this.onSizeChangedAdjust,
  }) : super(key: key, child: child);

  final SizeChangedCallback onSizeChanged;
  final SizeChangedCallback onSizeChangedAdjust;

  @override
  _SizeListenableRenderObject createRenderObject(BuildContext context) {
    return _SizeListenableRenderObject(
      onSizeChanged: onSizeChanged,
      onSizeChangedAdjust: onSizeChangedAdjust,
    );
  }
}

class _SizeListenableRenderObject extends RenderProxyBox {
  _SizeListenableRenderObject({
    RenderBox child,
    this.onSizeChanged,
    this.onSizeChangedAdjust,
  }) : super(child);

  final SizeChangedCallback onSizeChanged;
  final SizeChangedCallback onSizeChangedAdjust;

  Size _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    if (onSizeChanged == null && onSizeChangedAdjust == null) return;

    final Size size = this.size;
    if (size != _oldSize) {
      _oldSize = size;
      _callback(size);
    }
  }

  void _callback(Size size) {
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      if (onSizeChanged != null) onSizeChanged(size);
      if (onSizeChangedAdjust != null) onSizeChangedAdjust(size);
    });
  }
}
