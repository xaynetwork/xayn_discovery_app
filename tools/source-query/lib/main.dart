import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:source_query/results.dart' as res;

const topics = {
  'news',
  'sport',
  'tech',
  'world',
  'finance',
  'politics',
  'business',
  'economics',
  'entertainment',
  'beauty',
  'travel',
  'music',
  'food',
  'science',
  'gaming',
  'energy',
};

final lang = {
  'AT_de',
  'BE_fr',
  'BE_nl',
  'CA_en',
  'CH_de',
  'DE_de',
  'ES_es',
  'GB_en',
  'IE_en',
  'NL_nl',
  'PL_pl',
  'US_en',
};

main() async {
  final results = Map.of(res.sources);
  final sources = <Future>[];
  final titles = <String, Future>{};

  Future _getTitle(String source) => getTitle(source: source).then((value) {
        final map = results.putIfAbsent(source, () => <String, dynamic>{});
        map.putIfAbsent('title', () => value);
      }).timeout(Duration(seconds: 30), onTimeout: () {});

  for (var l in lang) {
    for (var t in topics) {
      final l_c = l.split('_');
      sources.add(
          getSources(topic: t, countries: l_c[0], lang: l_c[1]).then((value) {
        for (var r in value) {
          titles.putIfAbsent(r, () => _getTitle(r));
          final map = results.putIfAbsent(r, () => <String, dynamic>{});
          final lang = map.putIfAbsent('lang', () => <String>{});
          lang.add(l);
          map['lang'] = lang.toSet();
        }
      }));
    }
  }
  // final list = await getSources(topic: 'food', countries: 'DE', lang: 'de');
  await Future.wait(sources);
  await Future.wait(titles.values);
  print(
      "const sources = <String, Map<String, dynamic>>${json.encode(results, toEncodable: (obj) {
    if (obj is Set) {
      return List<String>.of(obj.map((e) => e.toString()));
    } else {
      return obj;
    }
  })};");
  printE(results.length);
  printE(
      results.entries.where((element) => element.value['title'] != '').length);
  exit(0);
}

Future<List<String>> getSources({
  required String? topic,
  required String countries,
  required String lang,
}) async {
  final queryParameters = {
    'countries': countries,
    'lang': lang,
  };
  if (topic != null) {
    queryParameters['topic'] = topic;
  }
  final uri = Uri.https('api-gw.xaynet.dev', '_src', queryParameters);
  final response = await http.get(uri, headers: {
    HttpHeaders.authorizationHeader:
        'Bearer kchkjfJbtLLXWjVrHnHNwfn3wvF3jqMh9CHhTsnVds3qwH4nwrv7K3CbmMMj',
    HttpHeaders.contentTypeHeader: 'application/json',
  });
  if (response.statusCode != 200) {
    printE('Failed for: $countries $topic $lang -> ${response.reasonPhrase}');
    return [];
  }
  final sources = json.decode(response.body)['sources'];

  return List<String>.from(sources.map((s) => s.toString()));
}

Future<String> getTitle({
  required String source,
}) async {
  final queryParameters = <String, String>{};
  final uri = Uri.https(source, '', queryParameters);
  try {
    final client = new HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    var request = await client.getUrl(uri);
    request.followRedirects = true;
    request.headers.set(
      HttpHeaders.userAgentHeader,
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:98.0) Gecko/20100101 Firefox/98.0',
    );

    final response = await request.close();

    if (response.statusCode != 200) {
      printE(
          'Failed get title for: $source -> ${response.reasonPhrase} (${response.statusCode})');
      return '';
    }
    final body = await readResponse(response)
        .timeout(Duration(seconds: 20), onTimeout: () => '');
    final doc = parse(body);

    return doc.head
            ?.getElementsByTagName('title')
            .map((e) => e.text)
            .firstWhere((element) => element.isNotEmpty, orElse: () => '') ??
        '';
  } catch (e) {
    printE('Failed get title for: $source -> $e');
    return '';
  }
}

Future<String> readResponse(HttpClientResponse response) async {
  final contents = StringBuffer();
  await for (var data in response.transform(utf8.decoder)) {
    contents.write(data);
  }
  return contents.toString();
}

void printE(Object msg) => stderr.writeln(msg);
