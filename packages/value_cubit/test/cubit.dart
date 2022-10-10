import 'package:test/expect.dart';
import 'package:value_cubit/value_cubit.dart';

class CounterCubit extends RefreshValueCubit<int> {
  var _value = 0;
  Future<int> _getMyValueFromRepository() async => _value++;

  @override
  Future<void> emitValues() => incrementValue();

  Future<void> incrementValue() async {
    final result = await _getMyValueFromRepository();

    switch (result) {
      case 2:
        emit(const NoValueState());
        break;
      case 3:
      case 4:
      case 6:
        fail('Error');
      default:
        emit(ValueState(result));
    }
  }
}

void cubitStandardActions(CounterCubit counterCubit) {
  counterCubit.refresh();
  counterCubit.refresh();
  counterCubit.refresh();
  counterCubit.refresh().onError((error, stackTrace) {
    // Ignore error
  });
  counterCubit.refresh().onError((error, stackTrace) {
    // Ignore error
  });
  counterCubit.refresh();
  counterCubit.refresh().onError((error, stackTrace) {
    // Ignore error
  });
  counterCubit.refresh();
  counterCubit.refresh().then((_) {
    counterCubit.clear();
  });
}
