import 'package:flutter/foundation.dart';

class ApiConfig {
  // IP LAN de la máquina donde corre el backend.
  // Para Web se usa localhost; para móviles (emulador físico o dispositivo)
  // se usa la IP LAN para que la app encuentre el servidor.
  static const String _hostIp = '192.168.100.38';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    return 'http://$_hostIp:3000';
  }
}
