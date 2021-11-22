import 'dart:ui';

class SlicesPalette {
    final List<Color> _colors;

    SlicesPalette({required List<Color> colors}) : this._colors = colors ?? [];
    SlicesPalette.fromString({required List<String> colors})
        : this._colors = _fromHexList(colors);

    Color getColor(int index) {
        final idx = index % _colors.length;
        return _colors[idx];
    }
}

List<Color> _fromHexList(List<String> strings) {
    return strings.map((str) => _fromHex(str)).toList();
}

Color _fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
}