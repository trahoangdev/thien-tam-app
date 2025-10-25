// Environment configuration
const apiBase = String.fromEnvironment(
  'API_BASE',
  // For Android Emulator (ĐANG SỬ DỤNG)
  defaultValue: 'http://10.0.2.2:4000',

  // For Physical Device:
  // defaultValue: 'http://10.150.0.53:4000', // IP: 10.150.0.53 (cập nhật 25/10/2025)
);
