import 'slice_descriptor.dart';
import "package:flutter/material.dart";

/// General interface for pie chart descriptor where applications can extend this class
/// to override chart defintions based on its own data.
abstract class IPieChartDescriptor {
    /// Background color for the chart (can be null where no backgound is defined).
    Color? get backgroundColor;

    // Foreground color for stroke lines for slices (can be null where no lines are defined).
    Color? get foregroundColor;

    /// Pie chart radius size (based on widget size). Tipically this factor is set wight values
    /// between the interval (0, 1.0].
    double radiusFactor = 1;

    /// Color for rays at the grid system. A null value indicates no rays.
    Color get rayColor;

    /// Color for the grid system. A null value indicates no grid.
    Color get gridColor;

    /// Color for the slice shadows. A null value indicates no shadows.
    Color get shadowColor;

    /// Chart external rectangle frame color. A null value indicates no frame.
    Color get frameColor;

    /// Chart size.
    Size get size;

    /// Number of linear rays for the chart grid system.
    int get numberOfRays;

    /// Size of interior grid spacing for pie chart. This value is relative to chart radius size.
    double get gridFactor;

    /// List of slice descriptors.
    List<List<ISliceDescriptor?>?> get sliceDescriptors;

    setSliceDescriptors(List<List<ISliceDescriptor?>?> sliceDescriptors);

    ISliceDescriptor? get sliceSelected;

    setSliceSelected(ISliceDescriptor? selected);

    /// Size of interior hole radius for pie chart, which adjust a ring drawing style.
    /// This value is relative to chart radius size.
    double get ringFactor;

    /// Start slice drawing angle.
    double get startAngle;

    /// Flag for indicating clockwise slice drawing direction.
    bool get clockwise;

    Path? selectedPath;

    bool isDrawValues = true;

    bool isShowHighlight = true;
}