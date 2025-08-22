import 'package:farmodo/data/services/animal_service.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/feature/auth/login/viewmodel/login_controller.dart';
import 'package:farmodo/feature/auth/register/viewmodel/register_controller.dart';
import 'package:farmodo/feature/store/viewmodel/reward_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/tasks_controller.dart';
import 'package:farmodo/feature/tasks/viewmodel/timer_controller.dart';
import 'package:get_it/get_it.dart';


final getIt = GetIt.instance;

Future<void> setupDependencies() async {

  //Data Services
  getIt.registerLazySingleton(() => AuthService());
  getIt.registerLazySingleton(() => FirestoreService());
  getIt.registerLazySingleton(() => AnimalService());

  // // DataSources
  // getIt.registerLazySingleton<MockCountryDataSources>(() => MockDataSourcesImpl());
  // getIt.registerLazySingleton<MockConnectionStatsDataSource>(() => MockConnectionStatsDataSourceImpl());
  // getIt.registerLazySingleton<MockFreeLocationsDataSources>(() => MockFreeLocationsDataSourcesImpl());
  

  // // Repositories
  // getIt.registerLazySingleton<CountryRepository>(() => CountryRepositoryImpl(getIt()));
  // getIt.registerLazySingleton<ConnectionStatsRepository>(() => ConnectionStatsRepositoryImpl(getIt()));
  // getIt.registerLazySingleton<FreeLocationsRepository>(() => FreeLocationsRepositoryImpl(getIt()));


  // // UseCases
  // getIt.registerLazySingleton<GetCountryUseCase>(() => GetCountryUseCase(getIt()));
  // getIt.registerLazySingleton<GetConnectionStatsUseCase>(() => GetConnectionStatsUseCase(getIt()));
  // getIt.registerLazySingleton<GetFreeLocationsUseCase>(() => GetFreeLocationsUseCase(getIt()));

  // ViewModels
  getIt.registerLazySingleton(() => TimerController());
  getIt.registerLazySingleton(() => LoginController(getIt()));
  getIt.registerLazySingleton(() => RegisterController(getIt()));
  getIt.registerLazySingleton(() => TasksController(getIt(), getIt(), getIt(), getIt()));
  getIt.registerLazySingleton(() => RewardController(getIt(), getIt(), getIt()));

}