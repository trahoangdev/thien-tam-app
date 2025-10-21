import 'package:dio/dio.dart';
import 'env.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: apiBase,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ),
);
