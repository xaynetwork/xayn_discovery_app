import 'dart:convert';
import 'dart:io';

import 'package:http_client/console.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@lazySingleton
class RequestLogger {
  RequestLogger();

  final List<ResultSet> _resultSets = <ResultSet>[];

  void addResultSet(ResultSet resultSet) => _resultSets.add(resultSet);

  Future<File> reportCurrentResultSets() async {
    var body = '';

    for (final resultSet in _resultSets) {
      final timeStamp =
          '${resultSet.timestamp.hour}h:${resultSet.timestamp.minute}m';
      final entry =
          '<p><b>${resultSet.path}: $timeStamp</b>&nbsp;<i>${resultSet.articles.length} results received</i><br>${resultSet.query}</p>';
      var listing = '<ol>';

      if (resultSet.path != '_lh') {
        var res = resultSet.articles;
        final actualLen = res.length;

        for (final article in res) {
          listing =
              '$listing<li>${article['published_date']}:&nbsp;<a href="${article['link']}">${const HtmlEscape().convert(article['title'])}</a>&nbsp;[${article['_score']}]</li>';
        }

        listing =
            '<span>Displaying top ${res.length} of $actualLen results: </span>$listing';
      }

      listing = '$listing</ol>';

      body = '$body$entry$listing';
    }

    final appDir = await getApplicationDocumentsDirectory();
    final filePath =
        appDir.uri.replace(path: 'stack_request_log.html').toString();
    final file = File(filePath);

    if (!file.existsSync()) file.createSync();

    return file..writeAsStringSync('<html><body>$body</body></html>');
  }
}

class ResultSet {
  final DateTime timestamp;
  final String path;
  final String query;
  final List<Map<String, dynamic>> articles;

  const ResultSet({
    required this.timestamp,
    required this.path,
    required this.query,
    required this.articles,
  });
}

class UniqueRequest {
  final http.Request request;
  final String lang;
  final List<String> countries;
  final int toRank;
  final int pageSize;
  final int page;
  final String sortBy;
  final String from;
  final String keywords;
  final int _hashCode;

  @override
  bool operator ==(Object other) {
    if (other is UniqueRequest) return hashCode == other.hashCode;

    return false;
  }

  @override
  int get hashCode => _hashCode;

  UniqueRequest.fromMap(
    Map<String, String> data, {
    required this.keywords,
    required this.request,
  })  : lang = data['lang']!,
        countries = data['countries']!.split(','),
        toRank = int.parse(data['to_rank']!),
        pageSize = int.parse(data['page_size']!),
        page = int.parse(data['page']!),
        sortBy = data['sort_by']!,
        from = data['from']!,
        _hashCode = Object.hashAll([
          keywords,
          data['lang'],
          data['countries'],
          data['page'],
        ]);
}
