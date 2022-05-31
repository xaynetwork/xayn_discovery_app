enum FeedMode {
  stream(0, "Stream mode"),
  carousel(1, "Carousel mode");

  final int raw;
  final String description;

  const FeedMode(this.raw, this.description);

  factory FeedMode.fromRaw(int rawValue) {
    return rawValue == FeedMode.carousel.raw
        ? FeedMode.carousel
        : FeedMode.stream;
  }
}
