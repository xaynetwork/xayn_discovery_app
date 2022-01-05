import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/widget/nav_bar_items.dart';
import 'package:xayn_discovery_app/presentation/onboarding/manager/onboarding_manager.dart';
import 'package:xayn_discovery_app/presentation/onboarding/manager/onboarding_state.dart';

import '../model/onboarding_page_data.dart';
import 'onboarding_page_builder.dart';

const kPageSwitchAnimationDuration = Duration(milliseconds: 400);
const kPageSwitchAnimationCurve = Curves.ease;
const kDotsIndicatorPositionFromBottom = 40.0;
const kOnBoardingPagesKeys = [
  Keys.onBoardingPageOne,
  Keys.onBoardingPageTwo,
  Keys.onBoardingPageThree,
];

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends State<OnBoardingScreen>
    with NavBarConfigMixin {
  late final OnBoardingManager _onBoardingManager = di.get();
  late final _pageController = PageController(initialPage: 0);
  late final List<OnBoardingPageData> _onBoardingPagesData =
      getInitialPageData();
  var _isOnboardingCompleted = false;

  @override
  NavBarConfig get navBarConfig => _isOnboardingCompleted
      ? NavBarConfig.backBtn(buildNavBarItemBack(
          onPressed: _onBoardingManager.onClosePressed,
        ))
      : NavBarConfig.hidden();

  @override
  void dispose() {
    _onBoardingManager.close();
    _pageController.dispose();
    super.dispose();
  }

  @visibleForTesting
  List<OnBoardingPageData> getInitialPageData() => [
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

  @override
  Widget build(BuildContext context) {
    final pageView = PageView.builder(
      controller: _pageController,
      itemBuilder: (_, index) => OnBoardingPageBuilder(
        key: kOnBoardingPagesKeys[index],
        onBoardingPageData: _onBoardingPagesData[index],
      ),
      itemCount: _onBoardingPagesData.length,
      onPageChanged: _onPageChanged,
      physics: const NeverScrollableScrollPhysics(),
    );

    final dotsIndicator = BlocBuilder<OnBoardingManager, OnBoardingState>(
      bloc: _onBoardingManager,
      buildWhen: (_, current) => _dotsIndicatorBuildWhen(current),
      builder: (_, state) => DotsIndicator(
        dotsNumber: _onBoardingPagesData.length,
        activePosition: state.currentPageIndex,
      ),
    );

    final stack = Stack(
      children: [
        GestureDetector(
          key: Keys.onBoardingPageTapDetector,
          onTap: _onPageTap,
          child: pageView,
        ),
        Positioned(
          right: .0,
          left: .0,
          bottom: kDotsIndicatorPositionFromBottom,
          child: dotsIndicator,
        ),
      ],
    );

    return Scaffold(
      backgroundColor: R.colors.onboardingTutorialBackground,
      body: SafeArea(
        child: stack,
      ),
    );
  }

  bool _dotsIndicatorBuildWhen(OnBoardingState state) => state.map(
        started: (_) => true,
        onPageChanged: (_) => true,
        completed: (_) => false,
        error: (_) => false,
      );

  void _onPageTap() async {
    final nextPageIndex = _pageController.page!.toInt() + 1;
    _pageController.animateToPage(
      nextPageIndex,
      duration: kPageSwitchAnimationDuration,
      curve: kPageSwitchAnimationCurve,
    );
  }

  void _onPageChanged(int newIndex) async {
    _onBoardingManager.onPageChanged(newIndex);
    final lastPageIndex = _onBoardingPagesData.last.index;

    if (newIndex == lastPageIndex) {
      _onBoardingManager.onOnBoardingCompleted(newIndex);
      _isOnboardingCompleted = true;
      NavBarContainer.updateNavBar(context);
    }
  }
}
