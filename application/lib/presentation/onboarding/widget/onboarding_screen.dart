import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/onboarding/manager/onboarding_manager.dart';
import 'package:xayn_discovery_app/presentation/onboarding/manager/onboarding_state.dart';
import 'package:xayn_discovery_app/presentation/widget/nav_bar_items.dart';

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
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with NavBarConfigMixin {
  late final OnBoardingManager _onBoardingManager;
  late final PageController _pageController;
  late final List<OnBoardingPageData> _onBoardingPagesData;

  var isCompleted = false;

  @override
  NavBarConfig get navBarConfig => isCompleted
      ? NavBarConfig.backBtn(buildNavBarItemBack(onPressed: () {
          Navigator.pop(context);
        }))
      : NavBarConfig.hide();

  @override
  void initState() {
    _onBoardingManager = di.get();
    _pageController = PageController(initialPage: 0);
    _initValues();
    super.initState();
  }

  @override
  void dispose() {
    _onBoardingManager.close();
    _pageController.dispose();
    super.dispose();
  }

  void _initValues() {
    _onBoardingPagesData = [
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
  }

  @override
  Widget build(BuildContext context) {
    final pageView = PageView.builder(
      controller: _pageController,
      itemBuilder: (_, index) => OnBoardingPageBuilder(
        key: kOnBoardingPagesKeys[index],
        onBoardingPageData: _onBoardingPagesData[index],
      ),
      itemCount: _onBoardingPagesData.length,
      onPageChanged: _onBoardingManager.onPageChanged,
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
          onTap: () => _onPageTap(
            pageController: _pageController,
          ),
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
        onPageChanged: (state) {
          if (!isCompleted &&
              state.currentPageIndex == _onBoardingPagesData.length - 1) {
            isCompleted = true;
            NavBarContainer.updateNavBar(context);
          }
          return true;
        },
        completed: (_) => false,
        error: (_) => false,
      );

  void _onPageTap({
    required PageController pageController,
  }) async {
    final lastPageIndex = _onBoardingPagesData.last.index;

    if (pageController.hasClients) {
      final currentPageIndex = pageController.page?.toInt() ?? 0;
      if (currentPageIndex == lastPageIndex) {
        await _onBoardingManager.onOnBoardingCompleted(currentPageIndex);
        return;
      }

      final nextPageIndex = currentPageIndex + 1;
      pageController.animateToPage(
        nextPageIndex,
        duration: kPageSwitchAnimationDuration,
        curve: kPageSwitchAnimationCurve,
      );
    }
  }
}
