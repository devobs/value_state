import 'package:test/test.dart';
import 'package:value_state/value_state.dart';

void main() {
  const myStrInitial = 'Initial';
  const myStr = 'My String';
  const myError = 'Test Error';
  const myOrElse = 'Or Else';

  group('when', () {
    test('on initial', () {
      expect(const Value<String>.initial().when(initial: () => myStrInitial),
          myStrInitial);
    });

    test('on success', () {
      expect(const Value.success(myStr).when(success: (data) => data), myStr);
    });

    test('on data', () {
      expect(const Value.success(myStr).when(data: (data) => data), myStr);
    });

    test('on data with error', () {
      expect(
          const Value.success(myStr).toFailure(myError).when(
                data: (data) => data,
                failure: (error) => myError,
              ),
          myStr);
    });

    test('on failure', () {
      expect(
          const Value<String>.initial().toFailure(myError).when(
                data: (data) => data,
                failure: (error) => error,
              ),
          myError);
    });

    test('on orElse', () {
      expect(
          const Value<String>.initial().when(
            data: (data) => myStr,
            orElse: () => myOrElse,
          ),
          myOrElse);
    });

    test('on fallback', () {
      expect(
          const Value<String>.initial().when(
            data: (data) => myStr,
          ),
          isNull);
    });
  });
}
