import 'package:flutter_test/flutter_test.dart';

import 'package:mmra_app/data.dart';

void main() {
  test('demo data is populated', () {
    expect(courses, isNotEmpty);
    expect(directoryRecords.keys, containsAll(['courts', 'judges', 'firms']));
  });
}
