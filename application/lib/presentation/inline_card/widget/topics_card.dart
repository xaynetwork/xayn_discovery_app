import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/manager/topics_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/topic/manager/topics_state.dart';
import 'package:xayn_discovery_app/presentation/widget/animation_player.dart';

import '../../feed_settings/topic/widget/topic_chip.dart';

class TopicsInLineCard extends StatefulWidget {
  const TopicsInLineCard({
    Key? key,
  }) : super(key: key);

  @override
  State<TopicsInLineCard> createState() => _TopicsInLineCardState();
}

class _TopicsInLineCardState extends State<TopicsInLineCard> {
  late final manager = di.get<TopicsManager>();

  @override
  Widget build(BuildContext context) {
    final column = BlocBuilder<TopicsManager, TopicsState>(
        bloc: manager,
        builder: (_, state) {
          final ctaString = manager.customSelectedTopicsCount == 0
              ? 'or enter your own topics'
              : '+${manager.customSelectedTopicsCount} custom topics';
          final children = <Widget>[
            SizedBox(height: R.dimen.unit),
            Expanded(child: _buildAnimation()),
            SizedBox(height: R.dimen.unit3),
            Text(
              R.strings.addTopicScreenTitle,
              textAlign: TextAlign.center,
              style: R.styles.lBoldStyle.copyWith(color: R.colors.brightText),
            ),
            SizedBox(height: R.dimen.unit2),
            Text(
              'Please select the topics that may interest you',
              textAlign: TextAlign.center,
              style: R.styles.mStyle.copyWith(color: R.colors.brightText),
            ),
            SizedBox(height: R.dimen.unit2_5),
            Wrap(
              spacing: R.dimen.unit,
              children: state.suggestedTopics
                  .map(
                    (it) => TopicChip(
                      topic: it,
                      onPressed: manager.onAddOrRemoveTopic,
                      isSelected: manager.isSelected(it),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: R.dimen.unit2),
            AppGhostButton(
              onPressed: manager.onAddTopicButtonClicked,
              child: Text(
                ctaString,
                textAlign: TextAlign.center,
                style: R.styles.sBoldStyle.copyWith(
                  color: R.colors.chipBorderColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ];
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          );
        });
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
              decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                R.colors.videoBackground,
                R.colors.snippetBackground,
                R.colors.snippetBackground,
                R.colors.videoBackground,
                R.colors.videoBackground,
              ],
              stops: const <double>[0.0, 0.13, 0.33, 0.44, 1.0],
            ),
          )),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: R.dimen.unit4,
            vertical: R.dimen.unit6,
          ),
          child: column,
        ),
      ],
    );
  }

  Widget _buildAnimation() => AnimationPlayer.assetUnrestrictedSize(
      R.linden.assets.lottie.contextual.createCollection);
}
