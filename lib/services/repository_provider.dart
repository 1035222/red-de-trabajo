import 'package:red_de_trabajo/services/api_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/service_repository.dart';
import '../repositories/chat_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/mock_repositories.dart';
import '../repositories/api_auth_repository.dart';
import '../repositories/api_service_repository.dart';
import '../repositories/api_chat_repository.dart';
import '../repositories/api_notification_repository.dart';
import '../repositories/api_profile_repository.dart';

class RepositoryProvider {
  static bool useMock = false;
  static final ApiService _apiService = ApiService();
  static AuthRepository? _authRepository;
  static ServiceRepository? _serviceRepository;
  static ChatRepository? _chatRepository;
  static NotificationRepository? _notificationRepository;
  static ProfileRepository? _profileRepository;

  static ApiService get apiService => _apiService;

  static AuthRepository get authRepository {
    if (useMock) return MockAuthRepository();
    _authRepository ??= ApiAuthRepository(_apiService);
    return _authRepository!;
  }

  static ServiceRepository get serviceRepository {
    if (useMock) return MockServiceRepository();
    _serviceRepository ??= ApiServiceRepository(_apiService);
    return _serviceRepository!;
  }

  static ChatRepository get chatRepository {
    if (useMock) return MockChatRepository();
    _chatRepository ??= ApiChatRepository(_apiService);
    return _chatRepository!;
  }

  static NotificationRepository get notificationRepository {
    if (useMock) return MockNotificationRepository();
    _notificationRepository ??= ApiNotificationRepository(_apiService);
    return _notificationRepository!;
  }

  static ProfileRepository get profileRepository {
    if (useMock) return MockProfileRepository();
    _profileRepository ??= ApiProfileRepository(_apiService);
    return _profileRepository!;
  }
}
