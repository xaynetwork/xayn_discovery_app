enum FeedMode {
  stream(0),
  carousel(1);

  final int _raw;
  int get raw => _raw;

  const FeedMode(this._raw);

  factory FeedMode.fromRaw(int rawValue) {
    assert(FeedMode.stream.raw <= rawValue);
    assert(rawValue <= FeedMode.carousel.raw);

    return rawValue == FeedMode.carousel.raw
        ? FeedMode.carousel
        : FeedMode.stream;
  }
}
