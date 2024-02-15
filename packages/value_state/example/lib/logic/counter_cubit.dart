import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:value_state/value_state.dart';

import 'repository.dart';

class CounterCubit extends Cubit<Value<int>> {
  CounterCubit() : super(const Value.initial());

  final _myRepository = MyRepository();

  Future<void> increment() =>
      state.fetchFrom(_myRepository.getValue).forEach(emit);
}
