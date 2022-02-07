import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' as dom;

abstract class CustomElement extends StatelessWidget {
  final dom.Element element;

  const CustomElement({
    Key? key,
    required this.element,
  }) : super(key: key);
}
