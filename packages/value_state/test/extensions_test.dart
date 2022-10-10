import 'package:test/test.dart';
import 'package:value_state/value_state.dart';

void main() {
  test('perform on $ValueState', () {
    final stream =
        const ValueState<int>(1).perform((state) async => const ValueState(2));

    expect(
        stream,
        emitsInOrder([
          const ValueState(1, refreshing: true),
          const ValueState(2, refreshing: false),
        ]));
  });

  test('performStream on $ValueState', () {
    final stream = const ValueState<int>(1).performStream((state) async* {
      yield const ValueState(2);
      yield const ValueState(3);
    });

    expect(
        stream,
        emitsInOrder([
          const ValueState(1, refreshing: true),
          const ValueState(2, refreshing: false),
          const ValueState(3, refreshing: false),
        ]));
  });
}
