import 'package:flutter/foundation.dart';

mixin LoadingMixin {
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);

  bool get isLoading => _isLoadingNotifier.value;

  ValueNotifier<bool> get isLoadingNotifier => _isLoadingNotifier;

  void setLoading(bool value) {
    _isLoadingNotifier.value = value;
  }

  void toggleLoading() {
    _isLoadingNotifier.value = !_isLoadingNotifier.value;
  }
}
