import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lottie/lottie.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class OnboardingBottomSheet extends BottomSheetBase {
  OnboardingBottomSheet({
    Key? key,
    required OnboardingType type,
    required VoidCallback onDismiss,
  }) : super(
          key: key,
          body: _OnboardingView(type: type, onDismiss: onDismiss),
          onSystemPop: onDismiss,
        );
}

class _OnboardingView extends HookWidget with BottomSheetBodyMixin {
  final OnboardingType type;
  final VoidCallback onDismiss;

  const _OnboardingView({
    Key? key,
    required this.type,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hooks
    final animationController = useAnimationController();
    // ignore: invalid_use_of_protected_member
    animationController.clearStatusListeners();
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.forward(from: 0);
      }
    });

    final text = _buildText();
    final children = <Widget>[
      SizedBox(height: R.dimen.unit),
      _buildAnimation(animationController),
      SizedBox(height: R.dimen.unit2),
      _buildTitle(),
      if (text != null) SizedBox(height: R.dimen.unit2),
      if (text != null) text,
      SizedBox(height: R.dimen.unit2_5),
      _buildCloseBtn(context),
    ];
    final column = Column(
      children: children,
      mainAxisSize: MainAxisSize.min,
    );
    return column;
  }

  Widget _buildAnimation(AnimationController controller) {
    final animation = Lottie.asset(
      _getAnimationPath(),
      repeat: true,
      controller: controller,
      onLoaded: (composition) {
        controller
          ..duration = composition.duration
          ..forward();
      },
    );
    return SizedBox(
      width: R.dimen.unit29,
      height: R.dimen.unit29,
      child: animation,
    );
  }

  Widget _buildCloseBtn(BuildContext context) => SizedBox(
        width: double.maxFinite,
        child: AppGhostButton.text(
          R.strings.general.btnClose,
          backgroundColor: R.colors.bottomSheetCancelBackgroundColor,
          onPressed: () {
            onDismiss();
            closeBottomSheet(context);
          },
        ),
      );

  Widget _buildTitle() {
    late final String text;
    switch (type) {
      case OnboardingType.homeVerticalSwipe:
        text = R.strings.onboardingBottomDialog.homeSwipeVerticalTitle;
        break;
      case OnboardingType.homeHorizontalSwipe:
        text = R.strings.onboardingBottomDialog.homeSwipeSideTitle;
        break;
      case OnboardingType.homeBookmarksManage:
        text = R.strings.onboardingBottomDialog.homeManageBookmarksTitle;
        break;
      case OnboardingType.collectionsManage:
        text = R.strings.onboardingBottomDialog.collectionManageTitle;
        break;
      case OnboardingType.bookmarksManage:
        text = R.strings.onboardingBottomDialog.bookmarksManageTitle;
        break;
    }
    return BottomSheetHeader(headerText: text);
  }

  Widget? _buildText() {
    late final String text;
    switch (type) {
      case OnboardingType.homeVerticalSwipe:
        text = R.strings.onboardingBottomDialog.homeSwipeVerticalMsg;
        break;
      case OnboardingType.homeHorizontalSwipe:
      case OnboardingType.homeBookmarksManage:
      case OnboardingType.collectionsManage:
      case OnboardingType.bookmarksManage:
        return null;
    }
    return Text(
      text,
      textAlign: TextAlign.center,
    );
  }

  String _getAnimationPath() {
    switch (type) {
      case OnboardingType.homeVerticalSwipe:
        return R.assets.lottie.feedSwipeVertical;
      case OnboardingType.homeHorizontalSwipe:
        return R.assets.lottie.feedSwipeHorizontal;
      case OnboardingType.homeBookmarksManage:
        return R.assets.lottie.bookmarkClick;
      case OnboardingType.collectionsManage:
        return R.assets.lottie.manageCollection;
      case OnboardingType.bookmarksManage:
        return R.assets.lottie.manageCollection;
    }
  }
}
