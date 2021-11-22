import 'dart:ui';
import "package:flutter/material.dart";

import 'chart_descriptor.dart';
import 'slice_descriptor.dart';

/// Generic painter tha the customized widget.
class LegendPainter extends CustomPainter {
  /// Piechar descriptor.
  IPieChartDescriptor _descriptor;

  set descriptor(IPieChartDescriptor _descriptor) {
    this._descriptor = _descriptor;
  }

  /// Default contructor with a `descriptor` parameter.
  LegendPainter(IPieChartDescriptor descriptor) :
        this._descriptor = descriptor{
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final fullRect = Rect.fromCenter(center: center, width: size.width, height: size.height);
    canvas.clipRect(fullRect, clipOp: ClipOp.intersect);

    canvas.save();
    canvas.restore();
  }

}