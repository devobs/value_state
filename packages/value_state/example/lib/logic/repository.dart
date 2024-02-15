class MyRepository {
  var _value = 0;

  Future<int> getValue() async {
    // Emulate a network request delay
    await Future.delayed(const Duration(milliseconds: 500));

    final value = _value++;

    if (value == 2) {
      throw 'Error';
    }
    return value;
  }
}
