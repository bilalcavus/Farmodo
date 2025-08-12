import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/firestore_service.dart';
import 'package:farmodo/viewmodel/auth/login/login_controller.dart';
import 'package:farmodo/viewmodel/auth/register/register_controller.dart';
import 'package:farmodo/viewmodel/tasks/tasks_controller.dart';
import 'package:farmodo/viewmodel/timer/timer_controller.dart';
import 'package:get_it/get_it.dart';


final getIt = GetIt.instance;

Future<void> setupDependencies() async {

  //Data Services
  getIt.registerLazySingleton(() => AuthService());
  getIt.registerLazySingleton(() => FirestoreService());

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
  getIt.registerLazySingleton(() => TasksController(getIt(), getIt()));

}