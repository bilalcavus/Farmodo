import 'package:farmodo/viewmodel/timer_controller.dart';
import 'package:get_it/get_it.dart';


final getIt = GetIt.instance;

Future<void> setupDependencies() async {

  //Constants
  // getIt.registerLazySingleton(() => ThemeController());

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

}