import 'package:test/test.dart';
import 'package:value_state/value_state.dart';

void main() {
  const myStr = 'My String';
  group('toState()', () {
    test('on a non null String', () {
      expect(myStr.toState(), const ValueState(myStr));
      expect(myStr.toState(refreshing: true),
          const ValueState(myStr, refreshing: true));
    });
    test('on null', () {
      const String? nullStr = null;

      expect(nullStr.toState(), const NoValueState<String>());
      expect(nullStr.toState(refreshing: true),
          const NoValueState<String>(refreshing: true));
    });
  });

  group('withValue', () {
    String? modifier(String value) => '$value modified';

    test('on a $ValueState', () {
      final result = myStr.toState().withValue(modifier);

      expect(result, modifier(myStr));
    });

    test('on a $ValueState', () {
      final result = const InitState<String>().withValue(modifier);

      expect(result, isNull);
    });

    test('expression on a $ValueState', () {
      String? result;
      myStr.toState().withValue((value) {
        result = modifier(value);
      });

      expect(result, modifier(myStr));
    });
  });
}
