import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/extract_elements_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/reader_mode/heuristic_filter_use_case.dart';
import 'package:xayn_readability/xayn_readability.dart';

import 'matchers.dart';

void main() {
  const tooShort = 'I am too short';
  const longEnough = 'I contain enough words, so please just some me already!';
  const screaming = 'I AM LOUD!!!!';
  const spammy = 'Hi, see https://www.foo.com and https://www.bar.com';
  const notSpammy =
      'The following document can be downloaded at https://www.foo.com';
  const result = ProcessHtmlResult(
    contents: '',
    themeColor: 4294967295,
    textSize: 136,
  );

  group('HeuristicFilterUseCase: ', () {
    useCaseTest<HeuristicFilterUseCase, Elements, Elements>(
      'filters out too short paragraphs: ',
      build: () => HeuristicFilterUseCase(),
      input: [
        const Elements(
          paragraphs: [
            tooShort,
            longEnough,
          ],
          processHtmlResult: result,
        ),
      ],
      expect: [
        elementsSuccess(
          const Elements(
            paragraphs: [
              longEnough,
            ],
            processHtmlResult: result,
          ),
        ),
      ],
    );

    useCaseTest<HeuristicFilterUseCase, Elements, Elements>(
      'filters out SCREAMING paragraphs: ',
      build: () => HeuristicFilterUseCase(),
      input: [
        const Elements(
          paragraphs: [
            screaming,
            longEnough,
          ],
          processHtmlResult: result,
        ),
      ],
      expect: [
        elementsSuccess(
          const Elements(
            paragraphs: [
              longEnough,
            ],
            processHtmlResult: result,
          ),
        ),
      ],
    );

    useCaseTest<HeuristicFilterUseCase, Elements, Elements>(
      'filters out link-only paragraphs: ',
      build: () => HeuristicFilterUseCase(),
      input: [
        const Elements(
          paragraphs: [
            spammy,
            notSpammy,
          ],
          processHtmlResult: result,
        ),
      ],
      expect: [
        elementsSuccess(
          const Elements(
            paragraphs: [
              notSpammy,
            ],
            processHtmlResult: result,
          ),
        ),
      ],
    );
  });
}
