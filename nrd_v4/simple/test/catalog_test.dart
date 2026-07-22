import 'package:flutter_test/flutter_test.dart';
import 'package:national_revival_desk/catalog.dart';

void main() {
  test('default categories are stable and complete', () {
    expect(defaultCategories.length, 29);
    expect(defaultCategories.first.slug, 'sunday-services');
    expect(defaultCategories.last.slug, 'disciplined-forces-ministries');
  });

  test('region formatter appends suffix and rejects typed suffix', () {
    expect(formatRegion('mombasa central'), 'Mombasa Central Region');
    expect(() => formatRegion('south region'), throwsFormatException);
  });
}
