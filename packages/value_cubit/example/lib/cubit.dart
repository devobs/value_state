import 'package:value_cubit/value_cubit.dart';

class CounterCubit extends ValueCubit<int> {
  var _value = 0;
  Future<int> _getMyValueFromRepository() async => _value++;

  CounterCubit() {
    increment();
  }

  Future<void> increment() => perform(() async {
        await Future.delayed(const Duration(seconds: 1));

        final result = await _getMyValueFromRepository();

        if (result == 2) {
          throw 'Error';
        } else if (result > 4) {
          emit(const NoValueState());
        } else {
          emit(ValueState(result));
        }
      });
}
