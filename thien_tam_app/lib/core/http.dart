import 'package:dio/dio.dart';
import 'env.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: apiBase,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ),
);
