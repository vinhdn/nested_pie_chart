import 'chart_descriptor.dart';
import 'slice_descriptor.dart';

/// Callbacks interface for [IPieChartDescriptor]
abstract class IPieChartCallbacks {

    /// Callback for user tap on char slice
    void tappedSlice(IPieChartDescriptor pieChartDescriptor, ISliceDescriptor tappedSlice);
}

/// Utility class for handling callbacks
class PieChartCallbacks extends IPieChartCallbacks {

    /// Tapped slice callback
    final void Function(IPieChartDescriptor, ISliceDescriptor) _tappedSlice;

    /// Default construtor
    PieChartCallbacks({ required Function(IPieChartDescriptor, ISliceDescriptor) tappedSlice}) :
            this._tappedSlice = tappedSlice;

    @override
    void tappedSlice(IPieChartDescriptor pieChartDescriptor, ISliceDescriptor tappedSlice) {
        if (_tappedSlice != null) _tappedSlice(pieChartDescriptor, tappedSlice);
    }
}