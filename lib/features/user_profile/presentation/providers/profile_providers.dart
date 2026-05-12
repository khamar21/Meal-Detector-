import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/profile_local_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/delete_profile_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/save_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

// ============ Data Sources ============
final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>(
  (ref) => const ProfileLocalDataSource(),
);

// ============ Repositories ============
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.read(profileLocalDataSourceProvider));
});

// ============ Use Cases ============
final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.read(profileRepositoryProvider));
});

final saveProfileUseCaseProvider = Provider<SaveProfileUseCase>((ref) {
  return SaveProfileUseCase(ref.read(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.read(profileRepositoryProvider));
});

final deleteProfileUseCaseProvider = Provider<DeleteProfileUseCase>((ref) {
  return DeleteProfileUseCase(ref.read(profileRepositoryProvider));
});
