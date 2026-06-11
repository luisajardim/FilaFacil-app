class ApiConstants {
  // Desktop/Web/iOS simulator: localhost
  // Android emulator: use 'http://10.0.2.2:3000'
  // Physical device: use your machine's LAN IP (e.g. 'http://192.168.1.x:3000')
  static const String baseUrl = 'http://localhost:3000';

  static const String fila = '/fila';
  static const String mesa = '/mesa';

  static const Duration pollingInterval = Duration(seconds: 7);
}
