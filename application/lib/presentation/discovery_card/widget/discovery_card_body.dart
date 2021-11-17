import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_readability/xayn_readability.dart';

class _ResultCardBody extends StatelessWidget {
  final PaletteGenerator? palette;

  Color? get dominantColor => palette?.colors.first;

  Color get textColor => (dominantColor?.computeLuminance() ?? .0) <= .5
      ? const Color(0xFFF8F8F8)
      : const Color(0xFF303030);

  const _ResultCardBody({
    Key? key,
    this.palette,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

/// The story page of a discovery card.
/// This typically contains a single html element that belongs to the reader mode.
class DiscoveryCardBody extends _ResultCardBody {
  final String snippet;
  final Widget footer;

  const DiscoveryCardBody({
    Key? key,
    required this.snippet,
    PaletteGenerator? palette,
    required this.footer,
  }) : super(key: key, palette: palette);

  @override
  Widget build(BuildContext context) {
    final snippetWidget = SnippetWidget(
      snippet: snippet,
      backgroundColor: R.colors.snippetBackground,
    );

    return Container(
      alignment: AlignmentDirectional.bottomCenter,
      padding: EdgeInsets.only(
          left: R.dimen.unit3,
          right: R.dimen.unit3,
          top: R.dimen.unit8,
          bottom: R.dimen.unit6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: snippetWidget,
            ),
          ),
          SizedBox(height: R.dimen.unit3),
          footer,
        ],
      ),
    );
  }
}

class SnippetWidget extends StatelessWidget {
  const SnippetWidget({
    Key? key,
    required this.snippet,
    required this.backgroundColor,
  }) : super(key: key);

  final String snippet;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final highlightedTextStyle = R.styles.snippetTextStyle?.copyWith(
      backgroundColor: backgroundColor,
    );

    final roundedHighlightsTextStyle = highlightedTextStyle?.copyWith(
        backgroundColor: null,
        background: Paint()
          ..color = backgroundColor
          ..strokeWidth = 5
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke);

    final centeredSnippet =
        '''<div style="text-align: center">$snippet<div/>''';

    // ref https://github.com/flutter/flutter/issues/29911
    // Flutter doesn't allow painting stroke with the fill at the same time
    // As a workaround, we stack both the fill and the rounded stroke highlight
    return Stack(children: [
      HtmlWidget(
        centeredSnippet,
        textStyle: highlightedTextStyle,
      ),
      HtmlWidget(
        centeredSnippet,
        textStyle: roundedHighlightsTextStyle,
      ),
    ]);
  }
}
