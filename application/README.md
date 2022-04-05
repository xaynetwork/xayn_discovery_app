# Xayn Discovery App

[Xayn Discovery](https://beta.xayn.com/) is your news assistant that discovers an endless stream of
news, articles and other content for you. Ad-free, loaded with privacy features and highly
personalised.

## Component overview ⚙️

The app is structured mainly to three components

### [domain](./lib/domain)

A pure Dart package where models and abstract repository classes live.

### [infrastructure](./lib/infrastructure)

A pure Dart package where use cases, repository implementation, and services live.

### [presentation](./lib/presentation)

A Flutter/Dart package where screens and widgets implementation live. The screens and widgets use
managers that utilize the the infrastructure code.

## Dependencies 📦

### Analytics platform integrations

| Dependency | Description |
| --- | --- |
| [Amplitude](https://github.com/amplitude/Amplitude-Flutter) | Amplitude platform helps in building analytics dashboards to better understand user behavior. You can check a list of events we send to Amplitude [here](#analytics-). |
| [AppsFlyer](https://github.com/AppsFlyerSDK/appsflyer-flutter-plugin) | A marketing analytics tool that helps in understanding how well marketing campaigns achieve their targets. |

### Xayn dependencies

| Dependency | Description |
| --- | --- |
| [xayn_design](https://github.com/xaynetwork/xayn_design) | Provides Xayn-styled shared design elements like icons, colors, styles, and themes. |
| [xayn_architecture](https://github.com/xaynetwork/xayn_architecture) | Provides the underlying of usecases and helpers that allow for cleaner functional code. |
| [xayn_swipe_it](https://github.com/xaynetwork/xayn_swipe_it) | Provides a performant, animated swipe widget with left and right customizable options that you can swipe or fling horizontally |
| [xayn_card_view](https://github.com/xaynetwork/xayn_card_view) | Provides a performant solution to scroll cards in Xayn's discovery feed |

### Other third party dependencies

| Dependency | Description |
| --- | --- |
| [Instabug](https://github.com/Instabug/Instabug-Flutter) | 1. A crash reporter tool that report crashes in the background so we build a more rebust app on the long run. <br/>2. In-app feedback feature -from the settings screen. |

For a more comprehensive list, check [pubspec.yaml](./pubspec.yaml).

## Analytics 📈

The analytics implementation can be found as part of
the [infrastructure/service/analytics](./lib/infrastructure/service/analytics). The platforms used
are mentioned briefly [here](#analytics).

### Events

An event is data sent to the analytics platforms when the user triggers an action.

#### Bookmarking/Saving an article

| Event | Description | Properties |
| --- | --- | --- |
| [bookmarkDeleted](./lib/infrastructure/service/analytics/events/bookmark_deleted_event.dart) | triggers when a bookmark is deleted from bookmarks screen | | `bool` **fromDefaultCollection**: is deleted from default collection ("Read later") |
| [bookmarkMoved](./lib/infrastructure/service/analytics/events/bookmark_moved_event.dart) | triggers when a bookmark is moved to another collection | `bool` **toDefaultCollection**: is moved to default collection ("Read later") |
| [collectionCreatedEvent](./lib/infrastructure/service/analytics/events/collection_created_event.dart) | triggers when a new collection is created | - |
| [collectionDeleted](./lib/infrastructure/service/analytics/events/collection_deleted_event.dart) | triggers when a collection is deleted | `enum` **deleteCollectionContext**: [moveBookmarks (when all bookmarks are moved), deleteBookmarks (when all bookmarks are deleted), empty (the collection was empty)] |
| [collectionRenamed](./lib/infrastructure/service/analytics/events/collection_renamed_event.dart) | triggers when a collection is renamed | - |
| [documentBookmarked](./lib/infrastructure/service/analytics/events/document_bookmarked_event.dart) | triggers when an article is bookmarked or unbookmarked | `bool` **isBookmarked**: is true when bookmarked, false when not.<br/>`Document` **document**: the article. |

#### Discovery screen/Swiping cards

| Event | Description | Properties |
| --- | --- | --- |
| [documentFeedbackChanged](./lib/infrastructure/service/analytics/events/document_feedback_changed_event.dart) | triggers when a like/dislike are clicked | `enum` **context**: [implicit, explicit]<br/>`Document` **document**: the article. |
| [documentIndexChanged](./lib/infrastructure/service/analytics/events/document_index_changed_event.dart) | triggers when a card is swiped | `enum` **direction**: [start, up, down]<br/>`Document` **nextDocument**: the article.|
| [documentShared](./lib/infrastructure/service/analytics/events/document_shared_event.dart) | triggers when a card is shared | `Document` **nextDocument**: the article.|
| [documentTimeSpent](./lib/infrastructure/service/analytics/events/document_time_spent_event.dart) | triggers when a card is clicked or swiped | `Duration` **duration**: the duration of time spent on the card. <br/>`enum` **viewMode**: [reader, story]<br/>`Document` **document**: the article.|
| [documentViewModeChanged](./lib/infrastructure/service/analytics/events/document_view_mode_changed_event.dart) | triggers when a card is clicked to open reader mode and when you return to the cards feed | `enum` **viewMode**: [reader, story]<br/>`Document` **document**: the article.|
| [nextFeedBatchRequestFailed](./lib/infrastructure/service/analytics/events/next_feed_batch_request_failed_event.dart) | triggers when the engine fails to get new cards | `NextFeedBatchRequestFailed` **nextFeedBatchRequestFailed**: error details.|
| [restoreFeedFailed](./lib/infrastructure/service/analytics/events/restore_feed_failed.dart) | triggers when restore feed exception occures | `RestoreFeedFailed` **restoreFeedFailed**: error object |

#### Card in reader mode

| Event | Description | Properties |
| --- | --- | --- |
| [readerModeBackgroundColorChanged](./lib/infrastructure/service/analytics/events/reader_mode_background_color_changed_event.dart) | triggers when reader mode background color is changed | `enum` **lightBackgroundColor**: [white, beige]<br/>`enum` **darkBackgroundColor**: [dark, trueBlack]|
| [readerModeFontSizeChanged](./lib/infrastructure/service/analytics/events/reader_mode_font_size_changed_event.dart) | triggers when reader mode font size is changed | `String` **fontSize**: a number |
| [readerModeFontStyleChanged](./lib/infrastructure/service/analytics/events/reader_mode_font_style_changed_event.dart) | triggers when reader mode font style is changed | `enum` **fontStyle**: [sans, serif] |
| [readerModeSettingsMenuDisplayed](./lib/infrastructure/service/analytics/events/reader_mode_settings_menu_displayed_event.dart) | triggers when reader mode menu is displayed | `bool` **isVisible** |

#### Subscription

| Event | Description | Properties |
| --- | --- | --- |
| [subscriptionAction](./lib/infrastructure/service/analytics/events/subscription_action_event.dart) | triggers when user taps on a button or link on the subscription window. | `enum` **action**: [subscribe, unsubscribe, cancel, restore, promoCode,]<br/>`Object?` **arguments**|
| [af_purchase](./lib/infrastructure/service/analytics/events/purchase_event.dart) | triggers when user subscribes. | `String` **af_price**: price<br/>`String` **af_currency**: currency<br/>`String` **af_content_id**: id of what is subscribed to|
| [openSubscriptionWindow](./lib/infrastructure/service/analytics/events/open_subscription_window_event.dart) | triggers when subsciption window is open. | `enum` **currentView**: [personalArea, settings, feed,]<br/>`Object?` **arguments**|

#### Generic

| Event | Description | Properties |
| --- | --- | --- |
| [bottomSheetDismissed](./lib/infrastructure/service/analytics/events/bottom_sheet_dismissed_event.dart) | triggers when a bottom menu is dismissed | `enum` **bottomSheetView**: [saveToCollection, moveMultipleBookmarksToCollection, createCollection, renameCollection, confirmDeletingCollection,]|
| [engineExceptionRaised](./lib/infrastructure/service/analytics/events/engine_exception_raised_event.dart) | triggers when an engine exception is raised | `String` **reason**: reason of failure.<br/>`String?` **message**</br>`String?` **stackTrace**|
| [engineInitFailed](./lib/infrastructure/service/analytics/events/engine_init_failed_event.dart) | triggers when an engine init exception occures | `Object` **error**|
| [openScreen](./lib/infrastructure/service/analytics/events/open_screen_event.dart) | triggers when switching screens. | `String` **screen**: name of the screen <br/> `Object?` **arguments**: arguments sent to the screen|
| [openExternalUrl](./lib/infrastructure/service/analytics/events/open_external_url_event.dart) | triggers when an external url is opened | `String` **url**: url opened <br/> `enum` **currentView**: [story, reader, settings]|

### User property

A user property is data tied to a user. It helps in creating user groups to visualize a user group
behavior.

| Parameter | Description  |
| --- | --- |
| [lastSeenDate](./lib/infrastructure/service/analytics/identity/last_seen_identity_param.dart) | The last date/time the user opened the app |
| [numberOfSelectedCountries](./lib/infrastructure/service/analytics/identity/number_of_active_selected_countries_identity_param.dart) | Number of countries a user selected |
| [numberOfBookmarks](./lib/infrastructure/service/analytics/identity/number_of_bookmarks_identity_param.dart) | Number of bookmarks a user has |
| [numberOfCollections](./lib/infrastructure/service/analytics/identity/number_of_collections_identity_param.dart) | Number of collections a user has |
| [numberOfTotalSessions](./lib/infrastructure/service/analytics/identity/number_of_total_sessions_identity_param.dart) | Number of total sessions a user has opened the app |

----------
