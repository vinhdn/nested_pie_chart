import 'dart:math';
import 'dart:ui';

import 'chart_descriptor.dart';
import 'slice_descriptor.dart';
import 'package:flutter/material.dart';

/// Demonstration pie chart descritor
class PieChartDescriptor implements IPieChartDescriptor {

    List<List<ISliceDescriptor?>?> slices = [];

    bool _drawValues = false;

    @override
    set isDrawValues(bool _isDrawValues) {
        _drawValues = _isDrawValues;
    }

    @override
    Color? get backgroundColor => Colors.cyan[50];

    @override
    Color? get foregroundColor => Colors.white;

    @override
    double radiusFactor = 0.8;

    @override
    Color get rayColor => Colors.grey;

    @override
    int get numberOfRays => 10;

    @override
    List<List<ISliceDescriptor?>?> get sliceDescriptors {
        return slices;
    }

    @override
    setSliceDescriptors(List<List<ISliceDescriptor?>?> sliceDescriptors) {
        slices = sliceDescriptors;
    }

    ISliceDescriptor? _sliceSelected;

    @override
    ISliceDescriptor? get sliceSelected => _sliceSelected;

    @override
    setSliceSelected(ISliceDescriptor? selected){
        _sliceSelected = selected;
    }

    @override
    Color get shadowColor => Colors.grey.withOpacity(0.9);

    @override
    Size get size => const Size(200, 200);

    @override
    Color get gridColor => Colors.grey;

    @override
    double get gridFactor => 0.20;

    @override
    Color get frameColor => Colors.black;

    @override
    double get ringFactor => 0.7;

    @override
    double get startAngle => pi / 2.0;

    @override
    bool get clockwise => true;

    @override
    Path? selectedPath;

    @override
    bool get isDrawValues => _drawValues;

    @override
    bool isShowHighlight = true;
}