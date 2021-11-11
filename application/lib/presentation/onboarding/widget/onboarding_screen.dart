import 'package:flutter/material.dart';

import '../model/onboarding_page_data.dart';
import 'onboarding_page_builder.dart';

const kPageSwitchAnimationDuration = Duration(milliseconds: 400);
const kPageSwitchAnimationCurve = Curves.ease;

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _pageController = PageController();

    final _onBoardingPagesData = [
      ///TODO Please replace mocked data with proper data
      const OnBoardingGenericPageData(
        imageAssetUrl: '',
        text: 'Swipe up for next article',
        index: 0,
      ),
      const OnBoardingGenericPageData(
        imageAssetUrl: '',
        text: 'Swipe right for liking',
        index: 1,
      ),
      const OnBoardingGenericPageData(
        imageAssetUrl: '',
        text: 'Swipe left for disliking',
        index: 2,
      ),
    ];

    final pageView = PageView.builder(
      controller: _pageController,
      itemBuilder: (_, index) => OnBoardingPageBuilder(
        onBoardingPageData: _onBoardingPagesData[index],
      ),
      itemCount: _onBoardingPagesData.length,
      physics: const NeverScrollableScrollPhysics(),
    );

    return Scaffold(
      /// TODO please use proper color from resources
      backgroundColor: Colors.black.withOpacity(0.85),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => _onPageTap(
            _pageController,
            _onBoardingPagesData.last.index,
          ),
          child: pageView,
        ),
      ),
    );
  }

  void _onPageTap(PageController pageController, int lastPageIndex) {
    final currentPageIndex = pageController.page?.toInt() ?? 0;
    if (currentPageIndex == lastPageIndex) {
      return;
    }

    if (pageController.hasClients) {
      final nextPageIndex = currentPageIndex + 1;
      pageController.animateToPage(
        nextPageIndex,
        duration: kPageSwitchAnimationDuration,
        curve: kPageSwitchAnimationCurve,
      );
    }
  }
}
