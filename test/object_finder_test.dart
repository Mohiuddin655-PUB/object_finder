import 'package:flutter_test/flutter_test.dart';
import 'package:object_finder/object_finder.dart';

void main() {
  group('ObjectFinder Extension Tests', () {
    test('Validity checks', () {
      Object? obj = 'Hello';
      expect(obj.isValid, true);
      expect(obj.isNotValid, false);
      expect(obj.verified, 'Hello');

      obj = null;
      expect(obj.isValid, false);
      expect(obj.isNotValid, true);
      expect(obj.verified, null);
    });

    test('Type checks', () {
      expect({'a': 1}.isMap, true);
      expect([1, 2, 3].isList, true);
      expect(
          [
            {'a': 1},
            {'b': 2}
          ].isListOfMap,
          true);
      expect([1, 2, 3].isListOfMap, false);
    });

    test('Equality check', () {
      final a = 5;
      final b = 5;
      final c = 5.0;
      expect(a.equals(b), true);
      expect(a.equals(c), false);
    });

    test('Primitive conversions', () {
      Object? numStr = "42";
      expect(numStr.find<int>(), 42);

      Object? doubleStr = "3.14";
      expect(doubleStr.find<double>(), 3.14);

      Object? boolStr = "true";
      expect(boolStr.find<bool>(), true);
    });

    test('List conversions', () {
      Object? list = ["1", "2", "3"];
      expect(list.finds<int>(), [1, 2, 3]);

      list = [1, 2, 3];
      expect(list.finds<String>(), ["1", "2", "3"]);
    });

    test('Nested map access', () {
      final data = {
        "user": {
          "id": "123",
          "roles": ["admin", "editor"]
        }
      };

      final id = data.get<Map>("user").find<int>(key: "id");
      final roles = data.get<Map>("user").finds<String>(key: "roles");

      expect(id, 123);
      expect(roles, ["admin", "editor"]);
    });

    test('Default values', () {
      final data = {"a": "1"};
      expect(data.findOrNull<int>(key: "b", defaultValue: 0), 0);
      expect(
          data.findsOrNull<String>(key: "c", defaultValue: ["none"]), ["none"]);
    });
  });
}
