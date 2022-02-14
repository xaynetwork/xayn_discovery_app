import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' as dom;
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/reader_mode/widget/custom_elements/custom_element.dart';

/// This will become a POEditor label eventually,
/// but we are awaiting a design here.
const String _kUnableToLoad = 'Unable to load this website';

/// Temporary Widget, proper website error screens are up for design.
/// For now, we use this Widget as a way to inform of any errors while testing
/// various site providers.
class ErrorElement extends CustomElement {
  const ErrorElement({
    Key? key,
    required dom.Element element,
  }) : super(key: key, element: element);

  @override
  Widget build(BuildContext context) {
    final statusCode = _buildHeader();

    return Container(
      padding: EdgeInsets.all(R.dimen.unit2),
      decoration: BoxDecoration(
        border: Border.all(
          color: R.colors.inputErrorText,
        ),
        borderRadius: BorderRadius.all(Radius.circular(R.dimen.unit)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (statusCode != null) statusCode,
              const Spacer(),
              _buildBody(),
            ],
          ),
          SizedBox(
            height: R.dimen.unit2,
          ),
          Text(
            _kUnableToLoad,
            style: R.styles.dialogErrorBody,
          )
        ],
      ),
    );
  }

  Widget? _buildHeader() {
    final statusCodeRaw = element.attributes['status-code'];
    final statusCode =
        statusCodeRaw != null ? int.tryParse(statusCodeRaw) : null;

    if (statusCode != null) {
      return Text(
        statusCode.toString(),
        style: R.styles.dialogTitleSmall,
      );
    }

    return null;
  }

  Widget _buildBody() {
    return Text(
      element.text,
      style: R.styles.dialogTitleSmall,
    );
  }
}
