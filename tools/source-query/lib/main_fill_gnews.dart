import 'dart:convert';
import 'dart:io';

import 'package:source_query/main_newscatcher.dart';

class Line {
  // Clean Domain Name;Domain Name;is_rss;Rank
  final String name;
  final String domain;
  final bool isRss;
  final int rank;

  Line(
      {required this.name,
      required this.domain,
      required this.isRss,
      required this.rank});

  factory Line.fromLine(String line) {
    final split = line.split(';');
    assert(split.length == 4);
    return Line(
        name: split[0],
        domain: split[1],
        isRss: split[2] == 'True',
        rank: int.tryParse(split[3]) ?? -1);
  }

  @override
  String toString() {
    final _name = name.trim().replaceAll(';', '');
    return '$_name;$domain;${isRss ? 'True' : 'False'};${rank >= 0 ? rank.toString() : ''}';
  }
}

void main(List args) async {
  final fileLines = File(args[0])
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .skip(1)
      .map((l) => Line.fromLine(l));
  // final lines = [Line.fromLine(';heise.de;;'), Line.fromLine(';163.com;;')];
  final List<Line> lines = await fileLines.toList();
  final results = <Line>[];
  var take = Iterable<Line>.empty();
  int total = 0;
  int totalNames = 0;
  do {
    take = lines.skip(total).take(500);
    var iterable = await Future.wait(take.map(_getTitle));
    results.addAll(iterable);
    total += iterable.length;
    totalNames += iterable.where((event) => event.name.isNotEmpty).length;
    printE('Finished ${total}, filled ${totalNames}');
  } while (take.isNotEmpty);

  // final list = await lines.toList();
  final finalNames = results.where((event) => event.name.isNotEmpty).length;
  results.forEach((element) {
    print(element.toString());
  });
  printE('Names filled ${finalNames}');
  exit(0);
}

Future<Line> _getTitle(Line element) {
  if (element.name.trim().isEmpty) {
    return getTitle(source: element.domain)
        .then((value) => Line(
            rank: element.rank,
            name: value,
            isRss: element.isRss,
            domain: element.domain))
        .timeout(Duration(seconds: 30), onTimeout: () => element);
  }
  return Future.value(element);
}
