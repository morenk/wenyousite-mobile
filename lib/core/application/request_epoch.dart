/// Rejects stale asynchronous completions after a newer request has started.
class RequestEpoch {
  int _value = 0;

  int begin() => ++_value;

  int get current => _value;

  bool isCurrent(int value) => value == _value;

  void invalidate() => _value += 1;
}
