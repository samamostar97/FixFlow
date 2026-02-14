import 'package:flutter_test/flutter_test.dart';
import 'package:fixflow_core/fixflow_core.dart';

void main() {
  test('PagedResult.empty returns empty result', () {
    final result = PagedResult<String>.empty();
    expect(result.items, isEmpty);
    expect(result.totalCount, 0);
  });

  test('FormValidators.required returns error for empty input', () {
    expect(FormValidators.required(null, 'Ime'), isNotNull);
    expect(FormValidators.required('', 'Ime'), isNotNull);
    expect(FormValidators.required('Test', 'Ime'), isNull);
  });
}
