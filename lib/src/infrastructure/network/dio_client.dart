import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../domain/failures/network_failure.dart';
import 'api_endpoints.dart';

/// Client réseau robuste basé sur Dio pour effectuer des requêtes au serveur.
/// Gère la configuration de base, les intercepteurs et la transformation des erreurs.
class DioClient {
  final Dio _dio;

  DioClient({Dio? dio}) : _dio = dio ?? Dio() {
    _dio
      ..options.baseUrl = ApiEndpoints.baseUrl
      ..options.connectTimeout = const Duration(
        milliseconds: ApiEndpoints.connectionTimeout,
      )
      ..options.receiveTimeout = const Duration(
        milliseconds: ApiEndpoints.receiveTimeout,
      )
      ..options.responseType = ResponseType.json
      ..interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
  }

  /// Effectue une requête GET.
  Future<Either<NetworkFailure, T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return Right(response.data as T);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Effectue une requête POST.
  Future<Either<NetworkFailure, T>> post<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return Right(response.data as T);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Effectue une requête PUT.
  Future<Either<NetworkFailure, T>> put<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return Right(response.data as T);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Effectue une requête DELETE.
  Future<Either<NetworkFailure, T>> delete<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return Right(response.data as T);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  /// Transforme les exceptions Dio en [NetworkFailure] compréhensibles par le domaine.
  NetworkFailure _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkFailure(type: NetworkFailureType.timeout);

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          String? serverMessage;

          if (responseData is Map<String, dynamic>) {
            serverMessage =
                responseData['erreur']?.toString() ??
                responseData['message']?.toString();
          }

          if (statusCode == 401 || statusCode == 403) {
            return NetworkFailure(
              type: NetworkFailureType.unauthorized,
              statusCode: statusCode,
              message: serverMessage ?? error.response?.statusMessage,
            );
          } else if (statusCode == 404) {
            return NetworkFailure(
              type: NetworkFailureType.notFound,
              statusCode: statusCode,
              message: serverMessage,
            );
          } else if (statusCode != null && statusCode >= 500) {
            return NetworkFailure(
              type: NetworkFailureType.serverError,
              statusCode: statusCode,
              message: serverMessage,
            );
          }
          return NetworkFailure(
            type: NetworkFailureType.unknown,
            statusCode: statusCode,
            message: serverMessage ?? error.response?.statusMessage,
          );

        case DioExceptionType.cancel:
          return const NetworkFailure(
            type: NetworkFailureType.unknown,
            message: 'Requête annulée',
          );

        case DioExceptionType.connectionError:
          return const NetworkFailure(type: NetworkFailureType.noConnection);

        default:
          if (error.error is SocketException) {
            return const NetworkFailure(type: NetworkFailureType.noConnection);
          }
          return const NetworkFailure(type: NetworkFailureType.unknown);
      }
    }
    return const NetworkFailure(type: NetworkFailureType.unknown);
  }
}
