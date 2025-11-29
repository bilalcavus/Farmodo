
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:farmodo/core/di/injection.dart';
import 'package:farmodo/core/services/adapty_billing_service.dart';
import 'package:flutter/material.dart';

class InitBilling {
  Future<void> initializeBilling() async {
    final configuration = AdaptyConfiguration(
      apiKey: 'public_live_m5Rz0ybh.sIaQdUoiIukEdjo7qb9w'
    );

    configuration.withObserverMode(false);

    await Adapty().activate(configuration: configuration);

    debugPrint("Adapty activated successfully");

    await getIt<AdaptyBillingService>().initialize();
  }
}