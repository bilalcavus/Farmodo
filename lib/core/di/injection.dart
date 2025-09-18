import 'package:farmodo/core/services/preferences_service.dart';
import 'package:farmodo/data/services/animal_service.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/data/services/gamification/gamification_service.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/auth/register/viewmodel/register_controller.dart';
import 'package:farmodo/feature/farm/viewmodel/farm_controller.dart';
import 'package:farmodo/feature/gamification/viewmodel/gamification_controller.dart';
import 'package:farmodo/feature/navigation/navigation_controller.dart';
import 'package:farmodo/feature/store/viewmodel/reward_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:get_it/get_it.dart';


final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Initialize SharedPreferences first
  await PreferencesService.init();

  //Core Services
  getIt.registerLazySingleton(() => PreferencesService.instance);

  //Data Services
  getIt.registerLazySingleton(() => AuthService());
  getIt.registerLazySingleton(() => FirestoreService());
  getIt.registerLazySingleton(() => AnimalService());
  getIt.registerLazySingleton(() => GamificationService());


  // ViewModels
  getIt.registerLazySingleton(() => TimerController());
  getIt.registerLazySingleton(() => LoginController(getIt()));
  getIt.registerLazySingleton(() => RegisterController(getIt()));
  getIt.registerLazySingleton(() => TasksController(getIt(), getIt(), getIt(), getIt()));
  getIt.registerLazySingleton(() => RewardController(getIt(), getIt(), getIt()));
  getIt.registerLazySingleton(() => GamificationController());
  getIt.registerLazySingleton(() => FarmController(getIt(), getIt()));
  getIt.registerLazySingleton(() => NavigationController());

}