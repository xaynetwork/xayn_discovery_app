import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:story/story.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

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
class DiscoveryCardBody extends _ResultCardBody {
  const DiscoveryCardBody({
    Key? key,
    PaletteGenerator? palette,
    required this.snippets,
  }) : super(key: key, palette: palette);
  final List<String> snippets;

  @override
  Widget build(BuildContext context) {
    Widget snippet(index) => Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.all(R.dimen.unit3),
            child: SnippetWidget(
              snippet: snippets.elementAt(index),
              backgroundColor: R.colors.snippetBackground,
            ),
          ),
        );

    return snippets.length < 2
        ? snippet(0)
        : StoryPageView(
            itemBuilder: (context, _, index) => snippet(index),
            storyLength: (_) => snippets.length,
            displayShadows: false,
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

    // ref https://github.com/flutter/flutter/issues/29911
    // Flutter doesn't allow painting stroke with the fill at the same time
    // As a workaround, we stack both the fill and the rounded stroke highlight
    return Stack(children: [
      Text(
        snippet,
        style: roundedHighlightsTextStyle,
        textAlign: TextAlign.center,
      ),
      Text(
        snippet,
        style: highlightedTextStyle,
        textAlign: TextAlign.center,
      ),
    ]);
  }
}
