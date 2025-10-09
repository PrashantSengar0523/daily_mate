
import 'package:dio/dio.dart';

class ApiException {
  static final ApiException _instance = ApiException._internal();
  factory ApiException() => _instance;
  ApiException._internal();

  String handleError(dynamic error, {Function()? onRetry}) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          onRetry;
          return "Connection timeout. Please try again later.";
        case DioExceptionType.badResponse:
          return "Invalid response. Please check the request.";
        case DioExceptionType.cancel:
          return "Request cancelled.";
        case DioExceptionType.connectionError:
          return "No internet connection. Please check your network.";
        default:
          return "Unexpected error occurred.";
      }
    }
    return "Something went wrong.";
  }
}
