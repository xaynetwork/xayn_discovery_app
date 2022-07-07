import 'dart:ffi';

import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_design/xayn_design.dart' as design;
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/util/string_extensions.dart';
import 'package:xayn_discovery_app/presentation/base_discovery/widget/reader_mode_unavailable_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/bookmark_options/bookmarks_options_menu.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/collection_options/collection_options_menu.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/contact_info/contact_info_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/create_or_rename_collection/widget/create_or_rename_collection_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/delete_collection_confirmation/delete_collection_confirmation_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/document_filter/widget/document_filter_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/error/generic_error_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/error/no_active_subscription_found_error_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/error/payment_failed_error_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_bookmarks_to_collection/widget/move_bookmarks_to_collection.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/widget/move_bookmark_to_collection.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/widget/move_document_to_collection.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/onboarding/widget/onboarding_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/promo_code/promo_code_applied_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/promo_code/redeem_promo_code_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/reset_ai/widget/reset_ai_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/reset_ai/widget/resetting_ai_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/payment/payment_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/subscription_details_bottom_sheet.dart';
import 'package:xayn_discovery_app/presentation/utils/string_utils.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

part 'overlay_data.freezed.dart';

/// Simple Marker Interface.
class OverlayData {
  OverlayData._();

  /// Tooltips
  ///
  static const maxDisplayableCollectionName = 20;

  static tooltipBookmarked({
    required Document document,
    required VoidCallback onTap,
    required VoidCallback? onClosed,
  }) {
    var defaultCollectionName = R.strings.defaultCollectionNameReadLater
        .truncate(maxDisplayableCollectionName);
    final label =
        R.strings.bookmarkSnackBarSavedTo.format(defaultCollectionName);
    return _wrapTooltip(
      design.TooltipData.customized(
        highlightText: defaultCollectionName,
        key: 'bookmarkedToDefault',
        label: label,
        onTap: onTap,
        icon: R.assets.icons.edit,
      ),
      onClosed: onClosed,
    );
  }

  static tooltipDocumentFilter({
    required VoidCallback onTap,
  }) =>
      _wrapTooltip(
        design.TooltipData.customized(
          key: 'documentFilter',
          label: R.strings.sourceHandlingTooltipLabel,
          highlightText: R.strings.sourceHandlingTooltipHighlightedWord,
          onTap: onTap,
        ),
      );

  static tooltipSourceExcluded({required VoidCallback onTap}) => _wrapTooltip(
        design.TooltipData.customized(
          key: 'sourceExcluded',
          label: R.strings.sourceExcludedTooltipMessage,
          highlightText: R.strings.manageSourcesTooltipMessage,
          onTap: onTap,
        ),
      );

  static tooltipSourceIncluded() => _wrapTooltip(
        design.TooltipData.customized(
          key: 'sourceIncluded',
          label: R.strings.sourceAllowedBackTooltipMessage,
        ),
      );

  static tooltipInvalidSearch() => _wrapTooltip(design.TooltipData.customized(
        key: 'invalidSearch',
        label: R.strings.invalidSearch,
        labelTextStyle: R.styles.tooltipHighlightTextStyle,
      ));

  static tooltipErrorMaxSelectedCountries(int maxSelectedCounties) =>
      _wrapTooltip(design.TooltipData.customized(
        key: 'feedSettingsScreenMaxSelectedCountries',
        label: R.strings.feedSettingsScreenMaxSelectedCountriesError
            .format(maxSelectedCounties.toString()),
        labelTextStyle: R.styles.tooltipHighlightTextStyle,
      ));

  static tooltipErrorMinSelectedCountries() =>
      _wrapTooltip(design.TooltipData.customized(
        key: 'feedSettingsScreenMinSelectedCountries',
        label: R.strings.feedSettingsScreenMinSelectedCountriesError,
        labelTextStyle: R.styles.tooltipHighlightTextStyle,
      ));

  static tooltipError(design.TooltipData data) => _wrapTooltip(data);

  static tooltipTextError(String text) =>
      _wrapTooltip(design.TooltipData.textual(key: text, label: text));

  static _wrapTooltip(design.TooltipData data, {VoidCallback? onClosed}) =>
      _TooltipOverlayData.tooltip(data: data, onClosed: onClosed);

  /// BottomSheets
  ///
  static BottomSheetData bottomSheetDocumentFilter(Document document) =>
      BottomSheetData<Document>(
          args: document,
          builder: (context, document) =>
              DocumentFilterBottomSheet(document: document!));

  static BottomSheetData bottomSheetOnboarding(
          OnboardingType type, VoidCallback onDismiss) =>
      BottomSheetData<OnboardingType>(
          args: type,
          builder: (__, _) =>
              OnboardingBottomSheet(type: type, onDismiss: onDismiss));

  static bottomSheetGenericError(
          {String? errorCode, bool allowStacking = false}) =>
      BottomSheetData<Void>(
        allowStacking: allowStacking,
        builder: (context, _) => GenericErrorBottomSheet(
          errorCode: errorCode,
        ),
      );

  static BottomSheetData bottomSheetMoveDocumentToCollection({
    required Document document,
    DocumentProvider? provider,
    FeedType? feedType,
    UniqueId? initialSelectedCollectionId,
    required VoidCallback onAddCollectionPressed,
    VoidCallback? onClose,
  }) =>
      BottomSheetData<Document>(
        args: document,
        builder: (context, document) => MoveDocumentToCollectionBottomSheet(
          document: document!,
          provider: provider,
          feedType: feedType,
          initialSelectedCollectionId: initialSelectedCollectionId,
          onAddCollectionPressed: onAddCollectionPressed,
          onClose: onClose,
        ),
      );

  static BottomSheetData bottomSheetContactInfo({
    required VoidCallback onXaynSupportEmailTap,
    required VoidCallback onXaynPressEmailTap,
    required VoidCallback onXaynUrlTap,
  }) =>
      BottomSheetData(
        builder: (context, document) => ContactInfoBottomSheet(
          onXaynPressEmailTap: onXaynPressEmailTap,
          onXaynSupportEmailTap: onXaynSupportEmailTap,
          onXaynUrlTap: onXaynUrlTap,
        ),
      );

  static BottomSheetData bottomSheetSubscriptionDetails({
    required SubscriptionStatus subscriptionStatus,
    required VoidCallback onSubscriptionLinkCancelTapped,
  }) =>
      BottomSheetData<SubscriptionStatus>(
        args: subscriptionStatus,
        builder: (context, subscriptionStatus) =>
            SubscriptionDetailsBottomSheet(
          subscriptionStatus: subscriptionStatus!,
          onSubscriptionLinkCancelTapped: onSubscriptionLinkCancelTapped,
        ),
      );

  static BottomSheetData bottomSheetPayment({
    required VoidCallback onClosePressed,
    required VoidCallback? onRedeemPressed,
  }) =>
      BottomSheetData(
        builder: (context, subscriptionStatus) => PaymentBottomSheet(
          onClosePressed: onClosePressed,
          onRedeemPressed: onRedeemPressed,
        ),
      );

  static BottomSheetData bottomSheetCreateOrRenameCollection({
    Collection? collection,
    VoidCallback? onSystemPop,
    Function(Collection)? onApplyPressed,
    bool showBarrierColor = true,
  }) =>
      BottomSheetData(
        showBarrierColor: showBarrierColor,
        builder: (_, __) => CreateOrRenameCollectionBottomSheet(
          collection: collection,
          onSystemPop: onSystemPop,
          onApplyPressed: onApplyPressed,
        ),
      );

  static BottomSheetData bottomSheetCollectionOptions({
    required Collection collection,
    required VoidCallback onClose,
    required VoidCallback onDeletePressed,
    required VoidCallback onRenamePressed,
  }) =>
      BottomSheetData<Collection>(
        showBarrierColor: false,
        args: collection,
        builder: (_, collection) => CollectionOptionsBottomSheet(
          collection: collection!,
          onSystemPop: onClose,
          onDeletePressed: onDeletePressed,
          onRenamePressed: onRenamePressed,
        ),
      );

  static BottomSheetData bottomSheetDeleteCollectionConfirmation({
    required UniqueId collectionId,
    required OnMoveBookmarksPressed onMovePressed,
    VoidCallback? onClose,
    bool showBarrierColor = true,
  }) =>
      BottomSheetData<UniqueId>(
        showBarrierColor: showBarrierColor,
        builder: (_, __) => DeleteCollectionConfirmationBottomSheet(
          collectionId: collectionId,
          onMovePressed: onMovePressed,
          onSystemPop: onClose,
        ),
      );

  static BottomSheetData bottomSheetPromoCodeApplied(PromoCode promoCode) =>
      BottomSheetData(
        builder: (_, __) => PromoCodeAppliedBottomSheet(promoCode: promoCode),
      );

  static BottomSheetData bottomSheetAlternativePromoCode(
          OnRedeemSuccessful onRedeemSuccessful) =>
      BottomSheetData(
        builder: (_, __) => RedeemPromoCodeBottomSheet(
          onRedeemSuccessful: onRedeemSuccessful,
        ),
      );

  static BottomSheetData bottomSheetBookmarksOptions({
    required UniqueId bookmarkId,
    required VoidCallback onClose,
    required VoidCallback onMovePressed,
  }) =>
      BottomSheetData<UniqueId>(
        args: bookmarkId,
        showBarrierColor: false,
        builder: (_, bookmarkId) => BookmarkOptionsBottomSheet(
          bookmarkId: bookmarkId!,
          onSystemPop: onClose,
          onMovePressed: onMovePressed,
        ),
      );

  static BottomSheetData bottomSheetMoveBookmarkToCollection({
    required UniqueId bookmarkId,
    VoidCallback? onSystemPop,
    UniqueId? initialSelectedCollection,
    bool showBarrierColor = true,
    required VoidCallback onAddCollectionPressed,
  }) =>
      BottomSheetData<UniqueId>(
        args: bookmarkId,
        showBarrierColor: showBarrierColor,
        builder: (_, bookmarkId) => MoveBookmarkToCollectionBottomSheet(
          bookmarkId: bookmarkId!,
          onSystemPop: onSystemPop,
          initialSelectedCollection: initialSelectedCollection,
          onAddCollectionPressed: onAddCollectionPressed,
        ),
      );

  static BottomSheetData bottomSheetReaderModeUnavailableBottomSheet({
    required VoidCallback? onOpenViaBrowser,
    required VoidCallback? onClosePressed,
    bool isDismissible = true,
  }) =>
      BottomSheetData(
        allowStacking: false,
        isDismissible: isDismissible,
        builder: (_, __) => ReaderModeUnavailableBottomSheet(
          onOpenViaBrowser: onOpenViaBrowser,
          onClosePressed: onClosePressed,
        ),
      );

  static BottomSheetData bottomSheetMoveBookmarksToCollection({
    required List<UniqueId> bookmarksIds,
    required UniqueId collectionIdToRemove,
    UniqueId? initialSelectedCollection,
    VoidCallback? onClose,
    required VoidCallback onAddCollectionPressed,
  }) =>
      BottomSheetData(
        showBarrierColor: false,
        builder: (_, __) => MoveBookmarksToCollectionBottomSheet(
          bookmarksIds: bookmarksIds,
          collectionIdToRemove: collectionIdToRemove,
          initialSelectedCollection: initialSelectedCollection,
          onSystemPop: onClose,
          onAddCollectionPressed: onAddCollectionPressed,
        ),
      );

  static BottomSheetData bottomSheetPaymentFailedError({
    bool allowStacking = true,
  }) =>
      BottomSheetData(
        allowStacking: allowStacking,
        builder: (_, __) => PaymentFailedErrorBottomSheet(),
      );

  static BottomSheetData bottomSheetNoActiveSubscriptionFoundError({
    bool allowStacking = true,
  }) =>
      BottomSheetData(
        allowStacking: allowStacking,
        builder: (_, __) => NoActiveSubscriptionFoundErrorBottomSheet(),
      );

  static BottomSheetData bottomSheetResetAI({
    required VoidCallback onResetAIPressed,
    VoidCallback? onSystemPop,
  }) =>
      BottomSheetData(
        builder: (_, __) => ResetAIBottomSheet(
          onSystemPop: onSystemPop,
          onResetAIPressed: onResetAIPressed,
        ),
      );
  static BottomSheetData bottomSheetResettingAI({
    VoidCallback? onSystemPop,
    bool isDismissible = false,
  }) =>
      BottomSheetData(
        isDismissible: isDismissible,
        builder: (_, __) => ResettingAIBottomSheet(
          onSystemPop: onSystemPop,
        ),
      );
}

@freezed
class _TooltipOverlayData extends OverlayData with _$_TooltipOverlayData {
  const factory _TooltipOverlayData.tooltip({
    required design.TooltipData data,
    // ignore: unused_element
    @Default(design.TooltipStyle.normal) design.TooltipStyle style,
    VoidCallback? onClosed,
  }) = TooltipData;
}

typedef BottomSheetBuilder<T> = design.BottomSheetBase Function(
    BuildContext context, T args);

class BottomSheetData<T> extends Equatable implements OverlayData {
  final BottomSheetBuilder<T?> builder;
  final T? args;
  final bool allowStacking;
  final bool isDismissible;
  final bool showBarrierColor;

  const BottomSheetData({
    required this.builder,
    this.allowStacking = true,
    this.isDismissible = true,
    this.showBarrierColor = true,
    this.args,
  });

  design.BottomSheetBase build(BuildContext context) => builder(context, args);

  @override
  List<Object?> get props => [builder, args];
}

extension OverlayDataExtension on OverlayData {
  void map({
    required void Function(TooltipData tooltip) tooltip,
    required void Function(BottomSheetData bottomSheet) bottomSheet,
  }) {
    if (this is _TooltipOverlayData) {
      (this as _TooltipOverlayData).map(tooltip: tooltip);
    } else if (this is BottomSheetData) {
      bottomSheet((this as BottomSheetData));
    } else {
      throw "Unimplemented OverlayData type: $this";
    }
  }
}
