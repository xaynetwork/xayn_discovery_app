import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/onboarding/manager/onboarding_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player.dart';

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

class _OnboardingView extends StatefulWidget {
  final OnboardingType type;
  final VoidCallback onDismiss;

  const _OnboardingView({
    Key? key,
    required this.type,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView>
    with BottomSheetBodyMixin, TickerProviderStateMixin {
  late final _manager = di.get<OnboardingManager>(param1: widget.type);

  @override
  Widget build(BuildContext context) {
    final text = _buildText();
    final children = <Widget>[
      SizedBox(height: R.dimen.unit),
      _buildAnimation(),
      SizedBox(height: R.dimen.unit2),
      _buildTitle(),
      if (text != null) SizedBox(height: R.dimen.unit2),
      if (text != null) text,
      SizedBox(height: R.dimen.unit2_5),
      _buildCloseBtn(),
    ];
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
    return column;
  }

  Widget _buildAnimation() => AnimationPlayer.asset(
        _getAnimationPath(),
        width: R.dimen.bottomSheetAnimationSize,
        height: R.dimen.bottomSheetAnimationSize,
      );

  Widget _buildCloseBtn() => SizedBox(
        width: double.maxFinite,
        child: AppGhostButton.text(
          R.strings.onboardingBottomDialog.cancelButton,
          backgroundColor: R.colors.bottomSheetCancelBackgroundColor,
          onPressed: () {
            _manager.onCancelPressed();
            widget.onDismiss();
            closeBottomSheet(context);
          },
        ),
      );

  Widget _buildTitle() {
    late final String text;
    switch (widget.type) {
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
    switch (widget.type) {
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
    switch (widget.type) {
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
