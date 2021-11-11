import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

import '../model/onboarding_page_data.dart';

const kPlaceHolderHeight = 200.0;
const kPlaceHolderWidth = 100.0;

class OnBoardingPageBuilder extends StatelessWidget {
  final OnBoardingPageData onBoardingPageData;

  const OnBoardingPageBuilder({
    required this.onBoardingPageData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPlaceHolderWidget,
        _buildSpacingWidget,
        _buildTextWidget
      ],
    );

    final position = Padding(
      padding: EdgeInsets.symmetric(horizontal: R.dimen.unit5),
      child: Center(
        child: column,
      ),
    );

    return position;
  }

  Widget get _buildPlaceHolderWidget => SizedBox(
        height: kPlaceHolderHeight,
        width: kPlaceHolderWidth,
        child: Placeholder(
          color: R.colors.brightText,
        ),
      );

  Widget get _buildSpacingWidget => SizedBox(height: R.dimen.unit5);

  Widget get _buildTextWidget => Text(
        onBoardingPageData.text,
        style: TextStyle(
          color: R.colors.brightText,
        ),
      );
}
