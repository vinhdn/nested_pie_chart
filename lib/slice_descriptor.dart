import 'dart:ui';

import 'package:flutter/material.dart';

/// General interface for slice definition inside a pie chart.
abstract class ISliceDescriptor {

    /// Numeric value associated to slice data
    double get value;

    /// Associated slice background color
    Color get color;

    /// Textual value for slice labelling.
    String? get label;

    String? get title;

    /// Label font size
    late double? labelSize;

    /// Label color
    Color? get labelColor;

    /// Slice detach factor relative to pie chart axis size.
    double? get detachFactor;


    set detachFactor(double? factor);

    /// Label radius factor relative to pie chart axis size.
    double? get labelFactor;

    bool get isSelected;

    int piePosition = 0;

    int slicePosition = 0;

    Path? path;

    double? yData;

    set selected(bool isSelected);

    Offset? highlight;

    int? serviceId;
    String? _serviceName;

    set serviceName(String? serviceName);

    String? get serviceName;
}

/// Standard concrete class for slice descriptors.
class SliceDescriptor extends ISliceDescriptor {

    /// Storage field for [ISliceDescriptor.value]
    double _value;

    /// Storage field for [ISliceDescriptor.color]
    Color _color;

    /// Storage field for [ISliceDescriptor.labelColor]
    Color? _labelColor;

    /// Storage field for [ISliceDescriptor.labelSize]
    double? _labelSize;

    /// Storage field for [ISliceDescriptor.detachFactor]
    double? _detachFactor;

    /// Storage field for [ISliceDescriptor.labelFactor]
    double? _labelFactor;

    /// Storage field for [ISliceDescriptor.label]
    String? _label;

    bool _isSelected = false;

    String? _title;

    /// Default constructor with standard required parameters `value`, `label` and `color`. All other parameters can be unset. This will produce a char with default configuration.
    SliceDescriptor(
        {required double value,
            required String label,
            required Color color,
            String? title,
            Color? labelColor,
            double? labelSize,
            double? detachFactor,
            double? textFactor})
        : _value = value,
            _color = color,
            _label = label,
            _title = title,
            _labelColor = labelColor,
            _labelSize = labelSize,
            _detachFactor = detachFactor,
            _labelFactor = textFactor;

    @override
    double get value => _value;

    @override
    Color get color => _color;

    @override
    String? get label => _label;

    @override
    Color? get labelColor => _labelColor;

    @override
    double? get labelSize => _labelSize;

    @override
    double? get detachFactor => _detachFactor;

    @override
    double? get labelFactor => _labelFactor;

    @override
    String? get title => _title;

    @override
    bool get isSelected => _isSelected;

    set value(double value) => _value = value;

    set color(Color color) => _color = color;

    set label(String? label) => _label = label;

    set title(String? label) => _title = label;

    set labelColor(Color? labelColor) => _labelColor = labelColor;

    set labelSize(double? labelSize) => _labelSize = labelSize;

    set detachFactor(double? detachFactor) => _detachFactor = detachFactor;

    set labelFactor(double? labelFactor) => _labelFactor = labelFactor;

    set selected(bool isSelected) => _isSelected = isSelected;

    @override
    set serviceName(String? serviceName) {
        _serviceName = serviceName;
    }

    @override
    String? get serviceName => _serviceName ?? "";

}