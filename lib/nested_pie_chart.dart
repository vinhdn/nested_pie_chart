import 'dart:collection';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'chart_callbacks.dart';
import 'pie_chart_descriptor.dart';

import 'chart_descriptor.dart';
import 'pie_chart_painter.dart';
import 'slice_descriptor.dart';

class NestedPieChartController {
    IPieChartDescriptor descriptor = PieChartDescriptor();
    PieChartCallbacks? callback;
    var random = Random(1);

    int partCount = 3;
    int sliceCount = 10;
    List<List<ISliceDescriptor>> slices = [];
    List<List<ISliceDescriptor>> originSlices = [];
    List<Color> colors = [];
    List<MapEntry<double, String>> groupDivision = [];
    List<Map<num, Map<String, dynamic>>> parseData = [];
    List<List<NestedPieData>> pieShowData = [];

    List<Color> chartColors = [];

    void onInit() {
        _initPieData();
        descriptor.setSliceDescriptors(slices);
        descriptor.isDrawValues = true;
        descriptor.radiusFactor = 0.85;
    }
    String longestLegend = "";

    void _initPieData() async {
        colors = _getColors().toList();

        slices.clear();
        originSlices.clear();
        pieShowData.clear();

        for(int i = 0; i < partCount; i++) {
            List<NestedPieData> slicePartData = [];
            for(int j = 0; j < sliceCount; j++) {
                final percent = random.nextDouble().abs() * 50.0;
                final pieData = NestedPieData(percent, percent, "Pie $i - $j", "Serice $i - $j");
                slicePartData.add(pieData);
            }
            pieShowData.add(slicePartData);
        }

        for(int i = 0; i < pieShowData.length; i++){
            final pieData = pieShowData[i];
            List<ISliceDescriptor> slicePart = [];
            List<ISliceDescriptor> originalPart = [];
            for(int k = 0; k < pieData.length; k++){
                final pie = pieData[k];
                final slice = SliceDescriptor(value: pie.percent, label: "${pie.percent.toStringAsFixed(1)}%", color: colors[k]);
                slice.slicePosition = k;
                slice.piePosition = i;
                slicePart.add(slice);
                originalPart.add(slice);
            }
            slices.add(slicePart);
            originSlices.add(originalPart);
        }
    }

    final defaultColor = [Color(0xFF03A9F4),
        Color(0xFFF44336),
        Color(0xFF4CAF50),
        Color(0xFF9C27B0),
        Color(0xFF00BCD4),
        Color(0xFFFF9800),
        Color(0xFF3F51B5),
        Color(0xFFFFEB3B),
        Color(0xFFE91E63),
        Color(0xFF607D8B)];

    List<Color> _getColors() {
        List<Color> colors = [];
        int length = colors.length;
        while(length < sliceCount) {
            colors.addAll(defaultColor);
            length += defaultColor.length;
        }

        return colors.sublist(0, sliceCount);
    }

    updateSelected(IPieChartDescriptor idescriptor, ISliceDescriptor? selected) {
        List<List<ISliceDescriptor>> newSliceDes = [];
        slices.forEach((allSlices) {
            List<ISliceDescriptor> newSlicePies = [];
            allSlices.forEach((s) {
                final slice = s as SliceDescriptor;
                slice.selected = false;
                if(selected != null && selected.piePosition == s.piePosition && selected.slicePosition == s.slicePosition) {
                    slice.selected = true;
                    slice.highlight = selected.highlight;
                    selected.serviceId = slice.serviceId;
                }
                newSlicePies.add(slice);
            });
            newSliceDes.add(newSlicePies);
        });
        slices = newSliceDes;

        descriptor.setSliceSelected(selected);
        descriptor.setSliceDescriptors(slices);
    }
}

class NestedPieChart extends StatefulWidget {
    const NestedPieChart({Key? key}) : super(key: key);

    @override
    State<StatefulWidget> createState() {
        return NestedPieChartState();
    }
}

class NestedPieChartState extends State<NestedPieChart> {

    double tooltipFontSize = 13;
    final NestedPieChartController _controller;

    NestedPieChartState(): _controller = NestedPieChartController() {
        _controller.onInit();
    }

    @override
    Widget build(BuildContext context) {
        return OrientationBuilder(builder: (context, orientation) {
            return Container(
                width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                minHeight: double.infinity, minWidth: double.infinity),
                            child: _getBody()
                        )
            ),
        );});
  }

    void setStateIfNotDispose() {
        if (mounted) {
            setState(() {});
        }
    }

    Widget _getBody() {
        return _disableScale(_controller.descriptor);
    }

    _highlight(PieChartPainter chartPainter, Offset offset) {
        final foundSlice = chartPainter.findSlice(offset);
        if (foundSlice != null) {
            _controller.updateSelected(_controller.descriptor, foundSlice);
            setStateIfNotDispose();
        }
    }

    Widget _disableScale(IPieChartDescriptor _descriptor) {
        final chartPainter = _buildChartPainter(_descriptor);
        return RawGestureDetector(
            gestures: {
                LongPressGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                        () => LongPressGestureRecognizer(debugOwner: this),
                        (LongPressGestureRecognizer instance) {
                        instance.onLongPressStart = (details) {
                            _highlight(chartPainter, details.localPosition);
                        };
                        instance.onLongPressMoveUpdate = (details) {
                            _highlight(chartPainter, details.localPosition);
                        };
                        instance.onLongPressEnd = (details) {
                            _controller.updateSelected(_controller.descriptor, null);
                            setStateIfNotDispose();
                        };
                    },
                ),
                TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                        () => TapGestureRecognizer(debugOwner: this),
                        (TapGestureRecognizer instance) {
                        instance.onTapUp = (details) {
                            _controller.updateSelected(_controller.descriptor, null);
                            setStateIfNotDispose();
                        };
                    })
            }, child: _buildCustomPaint(chartPainter));
    }

    PieChartPainter _buildChartPainter(IPieChartDescriptor descriptor) {
        return PieChartPainter(descriptor);
    }

    Widget _buildCustomPaint(PieChartPainter chartPainter) {
        return CustomPaint(
            size: Size.infinite,
            painter: chartPainter,
        );
    }
}
class NestedPieData {
    final double percent;
    final double value;
    final String title;
    final String serviceName;
    NestedPieData(this.percent, this.value, this.title, this.serviceName);
}
