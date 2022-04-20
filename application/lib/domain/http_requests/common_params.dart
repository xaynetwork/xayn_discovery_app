abstract class CommonHttpRequestParams {
  static const httpRequestOptions = 'OPTIONS';
  static const httpRequestGet = 'GET';
  static const Duration httpRequestTimeout = Duration(seconds: 8);
  static const int httpRequestMaxRedirects = 5;

  /// The order of headers matters!
  /// we attempt to mimic a real browser as much as possible.
  /// some providers do check header order, predominantly for blocking scrapers.
  static const Map<String, String> httpRequestHeaders = {
    'pragma': 'no-cache',
    'cache-control': 'no-cache',
    'sec-ch-ua':
        '" Not A;Brand";v="99", "Chromium";v="96", "Google Chrome";v="96"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform':
        '"Windows"', // we just want the host to think we're a real browser, the value just needs to pass checks on their side, nothing more
    'upgrade-insecure-requests': '1',
    'accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'sec-fetch-site': 'none',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-user': '?1',
    'sec-fetch-dest': 'document',
    'accept-language': 'en-GB,en;q=0.9,en-US;q=0.8,*;q=0.7',
    'accept-encoding': 'gzip',
    'connection': 'keep-alive',
    'content-type': 'text/html; charset=utf-8',
    'referer': 'http://www.google.com/',
  };
}
