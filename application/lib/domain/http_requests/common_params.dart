abstract class CommonHttpRequestParams {
  static const httpRequestOptions = 'OPTIONS';
  static const httpRequestGet = 'GET';
  static const Duration httpRequestTimeout = Duration(seconds: 8);
  static const int httpRequestMaxRedirects = 5;
  static const Map<String, String> httpRequestHeaders = {
    'accept': '*/*',
    'accept-encoding': 'gzip',
    'accept-language': '*',
    'cache-control': 'no-cache',
    'content-type': 'text/html; charset=utf-8',
    'pragma': 'no-cache',
    'sec-ch-ua':
        '" Not A;Brand";v="99", "Chromium";v="96", "Google Chrome";v="96"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform':
        'Windows', // we just want the host to think we're a real browser, the value just needs to pass checks on their side, nothing more
    'sec-fetch-dest': 'document',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-site': 'cross-site',
    'upgrade-insecure-requests': '1',
  };
}
