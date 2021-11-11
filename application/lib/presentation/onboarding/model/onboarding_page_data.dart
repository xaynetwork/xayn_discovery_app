abstract class OnBoardingPageData {
  final String imageAssetUrl;
  final String text;
  final int index;

  const OnBoardingPageData({
    required this.imageAssetUrl,
    required this.text,
    required this.index,
  });
}

class OnBoardingGenericPageData extends OnBoardingPageData {
  const OnBoardingGenericPageData({
    required String imageAssetUrl,
    required String text,
    required int index,
  }) : super(
          imageAssetUrl: imageAssetUrl,
          text: text,
          index: index,
        );
}
