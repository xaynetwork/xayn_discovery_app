enum FeedMode {
  stream(0),
  carousel(1);

  final int _raw;
  int get raw => _raw;

  const FeedMode(this._raw);

  factory FeedMode.fromRaw(int rawValue) {
    assert(rawValue < 2, "FeedMode raw value should be less than 2");
    return rawValue == FeedMode.carousel.raw
        ? FeedMode.carousel
        : FeedMode.stream;
  }
}
