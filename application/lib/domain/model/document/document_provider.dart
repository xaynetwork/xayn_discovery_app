import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_provider.freezed.dart';

@freezed
class DocumentProvider with _$DocumentProvider {
  factory DocumentProvider({
    String? name,
    Uri? favicon,
  }) = _DocumentProvider;
}
