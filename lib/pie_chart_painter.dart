import 'dart:ui';
import 'dart:math';
import "package:flutter/material.dart";

import 'chart_descriptor.dart';
import 'slice_descriptor.dart';

/// Generic painter tha the customized widget.
class PieChartPainter extends CustomPainter {
    /// Piechar descriptor.
    IPieChartDescriptor _descriptor;


    Map<ISliceDescriptor, Path> _pathMap = Map<ISliceDescriptor, Path>();

    /// Default contructor with a `descriptor` parameter.
    PieChartPainter(IPieChartDescriptor descriptor) :
            this._descriptor = descriptor{
    }

    @override
    bool shouldRepaint(CustomPainter oldDelegate) => true;

    @override
    void paint(Canvas canvas, Size size) {
        final radius = min(size.width, size.height) * 0.85;
        // _viewPortHandler.setChartDimens(radius, radius);
        final center = size.center(Offset.zero);
        final fullRect = Rect.fromCenter(center: center, width: size.width, height: size.height * 1.5);
        canvas.clipRect(fullRect, clipOp: ClipOp.intersect);

        // Pay attention to clear the path map!
        _pathMap.clear();

        final pieSquare = Rect.fromCenter(center: center, width: radius, height: radius);
        var paint = Paint();
        paint.isAntiAlias = true;

        _descriptor.sliceDescriptors.asMap().forEach((index, value) {
            final sum = _calculateSum(index) * 1;
            _drawSlices(canvas, paint, pieSquare, sum, false, index, value);
        });
        if (_descriptor.isDrawValues) {
            _descriptor.sliceDescriptors.asMap().forEach((index, value) {
                final sum = _calculateSum(index);
                _drawValues(canvas, paint, pieSquare, sum, false, index, value);
            });
        }

        canvas.save();
        canvas.restore();
        if (_descriptor.isShowHighlight && _descriptor.sliceSelected != null) {
            _drawTooltipSlice(canvas, paint, pieSquare, _descriptor.sliceSelected);
        }
    }

    /// Draws the background for the chart using the descriptor properties:
    /// [IPieChartDescriptor.backgroundColor] and [IPieChartDescriptor.frameColor].
    void _drawBackground(Canvas canvas, Paint paint, Rect fullRect) {
        var bgColor = this._descriptor.backgroundColor;
        _drawRectangle(canvas, paint, fullRect, bgColor, null);
    }

    /// Draws the background for the chart using the descriptor properties:
    /// [IPieChartDescriptor.backgroundColor] and [IPieChartDescriptor.frameColor].
    void _drawForeground(Canvas canvas, Paint paint, Rect fullRect) {
        var fgColor = this._descriptor.frameColor;
        paint.strokeWidth = 4.0;
        _drawRectangle(canvas, paint, fullRect, null, fgColor);
    }

    /// Draws a simple rectangle `rect` using `bgColor` and `fgColor` for the paint and stroke colors
    /// respectifully.
    void _drawRectangle(Canvas canvas, Paint paint, Rect rect, Color? bgColor, Color? fgColor) {
        if (bgColor != null) {
            paint.color = bgColor;
            paint.style = PaintingStyle.fill;
            canvas.drawRect(rect, paint);
        }
        if (fgColor != null) {
            paint.color = fgColor;
            paint.style = PaintingStyle.stroke;
            canvas.drawRect(rect, paint);
        }
    }

    /// Draws the arc based on current `paint` attributes for stroke and paint color.
    Path _drawArc(Canvas canvas, Paint paint, Offset center, double startRadius, double endRadius, double startRadian,
        double sweepRadian) {
        final path = _getArcPath(center, startRadius, endRadius, startRadian, sweepRadian);
        canvas.drawPath(path, paint);
        return path;
    }

    /// Get arc
    Path _getArcPath(Offset center, double startRadius, double endRadius, double startRadian, double sweepRadian) {
        final r1 = min(endRadius, startRadius);
        final r2 = max(endRadius, startRadius);
        final Path path = Path();
        final p1 = _calculateDirectedOffset(center, startRadian, r1);
        path.moveTo(p1.dx, p1.dy);
        path.arcTo(Rect.fromCircle(center: center, radius: r1), startRadian, sweepRadian, false);
        final p2 = _calculateDirectedOffset(center, startRadian + sweepRadian, r2);
        path.lineTo(p2.dx, p2.dy);
        path.arcTo(Rect.fromCircle(center: center, radius: r2), startRadian + sweepRadian, -sweepRadian, false);
        path.lineTo(p1.dx, p1.dy);
        path.close();
        return path;
    }

    /// Get arc
    Path _getArcCirclePath(Offset center, double startRadius, double endRadius, double startRadian, double sweepRadian) {
        final r1 = min(endRadius, startRadius);
        final r2 = max(endRadius, startRadius);
        final Path path = Path();
        final p1 = _calculateDirectedOffset(center, startRadian, r1);
        path.moveTo(p1.dx, p1.dy);
        path.addOval(Rect.fromCircle(center: center, radius: r1));
        path.addOval(Rect.fromCircle(center: center, radius: r2));
        path.close();
        return path;
    }


    /// Draws a circle based on current paint configuration.
    void _drawCircle(Canvas canvas, Paint paint, Offset center, double radius) {
        canvas.drawCircle(center, radius, paint);
    }

    /// Draws a single slice
    double _drawSlice(Canvas canvas, Paint paint, Rect square, ISliceDescriptor slice, double initAngle, double sum,
        Color bgColor, Color? fgColor, double direction, int index, {bool asShadow = false}) {
        double percent = (slice.value / sum);
        double angle = direction * percent * pi * 2;
        if(angle <= 0) return 0;
        final maxRadius = square.shortestSide / 2.0;
        final sliceWidth = maxRadius * 0.2;
        final scaleWidth = asShadow ? 1.1 : 0;
        final endRadius = maxRadius - sliceWidth * index + scaleWidth * 2;
        final startRadius = endRadius  - sliceWidth - scaleWidth/2;
        final centerAngle = initAngle + angle / 2.0;

        final center = square.center;
        var sliceCenter = center;

        var detachRatio = slice.detachFactor;
        if (detachRatio != null) {
            if (detachRatio < 0.0) detachRatio = 0.0;
            if (detachRatio > 1.0) detachRatio = 1.0;
            sliceCenter = _calculateDirectedOffset(center, centerAngle, endRadius * detachRatio);
        }
        paint.style = PaintingStyle.fill;
        paint.color = bgColor;
        if (percent == 1) {
            final path = _getArcCirclePath(center, startRadius, endRadius, initAngle, angle);
            canvas.drawPath(path, paint);
            _pathMap.putIfAbsent(slice, () => path);
            if (fgColor != null) {
                paint.style = PaintingStyle.stroke;
                paint.color = fgColor;
                paint.strokeWidth = 0.2;
                canvas.drawPath(path, paint);
            }
            Paint paintClear = Paint()..blendMode = BlendMode.clear..style = PaintingStyle.fill..color = bgColor;
            canvas.drawCircle(center, startRadius, paintClear);
            if(index == _descriptor.sliceDescriptors.length - 1) {
                Paint paintClear = Paint()..style = PaintingStyle.fill..color = Colors.white;
                canvas.drawCircle(center, startRadius, paintClear);
            }
        } else {
            final path = _drawArc(canvas, paint, sliceCenter, startRadius, endRadius, initAngle, angle);
            _pathMap.putIfAbsent(slice, () => path);
            if (fgColor != null) {
                paint.style = PaintingStyle.stroke;
                paint.color = fgColor;
                paint.strokeWidth = 0.2;
                _drawArc(canvas, paint, sliceCenter, startRadius, endRadius, initAngle, angle);
            }
        }

        return angle;
    }

    /// Draws a single slice value
    double _drawValue(Canvas canvas, Paint paint, Rect square, ISliceDescriptor slice, double initAngle, double sum,
        Color bgColor, Color? fgColor, Offset? offset, double direction, int index, {bool asShadow = false}) {
        final angle = direction * slice.value / sum * pi * 2;
        final maxRadius = square.shortestSide / 2.0;
        final sliceWidth = maxRadius * 0.2;
        final scaleWith = 0;
        final endRadius = maxRadius - sliceWidth * index + scaleWith * 2;
        final startRadius = endRadius  - sliceWidth - scaleWith/2;
        final centerAngle = initAngle + angle / 2.0;

        final center = offset != null ? square.center.translate(offset.dx, offset.dy) : square.center;
        var sliceCenter = center;

        var detachRatio = slice.detachFactor;
        if (detachRatio != null) {
            if (detachRatio < 0.0) detachRatio = 0.0;
            if (detachRatio > 1.0) detachRatio = 1.0;
            sliceCenter = _calculateDirectedOffset(center, centerAngle, endRadius * detachRatio);
        }
        paint.style = PaintingStyle.fill;
        paint.color = bgColor;
        final path = _pathMap[slice];
        if (!asShadow && path != null && slice.value >= 10) {
            final txtColor = slice.labelColor ?? Colors.black;
            final txtFactor = slice.labelFactor ?? 0.5;
            final txtSize = slice.labelSize ?? 8.0;
            final deltaRadius = endRadius - startRadius;
            final pt = _calculateDirectedOffset(sliceCenter, centerAngle, startRadius + (deltaRadius * txtFactor));

            final txtStyle = TextStyle(color: txtColor, fontSize: txtSize);
            final span = TextSpan(text: "${slice.label}", style: txtStyle);
            final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..textAlign = TextAlign.center;
            tp.layout();
            final bgWidth = tp.width * 1.3;
            final bgHeight = tp.height * 1.2;
            canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: pt, width: bgWidth, height: bgHeight), const Radius.circular(3)), paint..style = PaintingStyle.fill
            ..color = Colors.white);
            tp.paint(canvas, pt.translate(-bgWidth/3, -bgHeight/3));
        }

        return angle;
    }

    /// Draws a single slice
    double _drawTooltipSlice(Canvas canvas, Paint paint, Rect square, ISliceDescriptor? slice) {
        return 0;
    }

    /// Draw all the slices configured for the pie chart ([IPieChartDescriptor.slices]). The `asShadow`
    /// argument is defined for reuse while drawing shadows.
    void _drawSlices(Canvas canvas, Paint paint, Rect square, double sum, bool asShadow, int index, List<ISliceDescriptor?>? slices) {
        if (slices == null) return;
        final startAngle = -pi/2.0;
        final clockwise = _descriptor.clockwise;
        final direction = clockwise ? 1.0 : -1.0;
        final numSlices = slices.length;
        var angle = startAngle;
        for (int s = 0; s < numSlices; s++) {
            final slice = slices[s];
            if (slice == null) continue;
            Color bgColor = asShadow ? _descriptor.shadowColor : slice.color;
            if(!asShadow && !slice.isSelected) {
                bgColor = bgColor.withAlpha(255);
            } else {
                bgColor = bgColor.withAlpha(100);
            }
            final fgColor = asShadow ? null : _descriptor.foregroundColor;
            final sliceAngle = _drawSlice(canvas, paint, square, slice, angle, sum, bgColor, fgColor, direction, index, asShadow: asShadow);
            angle += sliceAngle;
        }
    }

    /// Draw all the slices configured for the pie chart ([IPieChartDescriptor.slices]). The `asShadow`
    /// argument is defined for reuse while drawing shadows.
    void _drawValues(Canvas canvas, Paint paint, Rect square, double sum, bool asShadow, int index, List<ISliceDescriptor?>? slices) {
        if (slices == null) return;
        final startAngle = -pi/2;
        final clockwise = _descriptor.clockwise;
        final direction = clockwise ? 1.0 : -1.0;
        final numSlices = slices.length;
        var angle = startAngle;
        for (int s = 0; s < numSlices; s++) {
            final slice = slices[s];
            if (slice == null) continue;
            final bgColor = asShadow ? _descriptor.shadowColor : slice.color;
            final fgColor = asShadow ? null : _descriptor.foregroundColor;
            final offset = asShadow ? const Offset(5, 5) : null;
            final sliceAngle = _drawValue(canvas, paint, square, slice, angle, sum, bgColor, fgColor, offset, direction, index);
            angle += sliceAngle;
        }
    }

    /// Calculate a new target offset based on a `src`.
    Offset _calculateDirectedOffset(Offset src, double angle, double distance) {
        final x = src.dx + cos(angle) * distance;
        final y = src.dy + sin(angle) * distance;
        final tgt = Offset(x, y);
        return tgt;
    }

    /// Calculates the sum of all slice values.
    double _calculateSum(int index) {
        final slices = _descriptor.sliceDescriptors[index];
        if (slices == null) return 0;
        final numSlices = slices.length;
        var sum = 0.0;
        for (int s = 0; s < numSlices; s++) {
            final slice = slices[s];
            if (slice == null) continue;
            sum += slice.value;
        }
        return sum;
    }

    /// Searches for a slice (path previosly stored) based on a coordinate ([offset]).
    /// Returns the slice descriptor.
    ISliceDescriptor? findSlice(Offset offset) {
        if (!_descriptor.isShowHighlight) return null;
        ISliceDescriptor? foundSlice;
        _pathMap.forEach((sld, pth) {
            if (pth.contains(offset)) {
                foundSlice = sld;
                foundSlice!.highlight = offset;
            }
        });
        return foundSlice;
    }
}