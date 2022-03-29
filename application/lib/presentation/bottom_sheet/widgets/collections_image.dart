import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_manager.dart';
import 'package:xayn_discovery_app/presentation/collections/manager/collection_card_state.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/thumbnail_widget.dart';

Widget buildCollectionImage(CollectionCardManager manager) =>
    BlocBuilder<CollectionCardManager, CollectionCardState>(
      bloc: manager,
      builder: (context, cardState) => cardState.image != null
          ? Thumbnail.memoryImage(cardState.image!)
          : Thumbnail.assetImage(
              R.assets.graphics.formsEmptyCollection,
              backgroundColor: R.colors.collectionsScreenCard,
            ),
    );
