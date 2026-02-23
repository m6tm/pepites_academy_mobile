import 'package:dio/dio.dart';
import '../../application/services/app_preferences.dart';
import 'api_endpoints.dart';

/// Intercepteur pour gérer l'ajout du token et le rafraîchissement automatique.
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final AppPreferences preferences;
  bool _isRefreshing = false;
  final _requestsQueue = <Map<String, dynamic>>[];

  AuthInterceptor({required this.dio, required this.preferences});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Si la requête est déjà pour le refresh ou le login, on ne fait rien
    if (options.path.contains('/auth/refresh') ||
        options.path.contains('/auth/login') ||
        options.path.contains('/auth/register')) {
      return handler.next(options);
    }

    final token = await preferences.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    if (response != null && response.statusCode == 401) {
      final isRefreshEndpoint = err.requestOptions.path.contains(
        '/auth/refresh',
      );
      final isLoginEndpoint = err.requestOptions.path.contains('/auth/login');

      if (!isRefreshEndpoint && !isLoginEndpoint) {
        if (_isRefreshing) {
          // Si on est déjà en train de rafraîchir, on met la requête en attente
          _requestsQueue.add({
            'options': err.requestOptions,
            'handler': handler,
          });
          return;
        }

        _isRefreshing = true;
        try {
          final refreshToken = await preferences.getRefreshToken();
          if (refreshToken == null) {
            _isRefreshing = false;
            // On le jette et déconnecte de force l'utilisateur
            await preferences.forceLogout(
              'Votre session a expiré. Veuillez vous reconnecter.',
            );
            return handler.next(err);
          }

          // Appel à l'API de refresh
          final refreshResponse = await Dio(
            BaseOptions(
              baseUrl: ApiEndpoints.baseUrl,
              headers: {'Authorization': 'Bearer $refreshToken'},
            ),
          ).post('/auth/refresh');

          final newAccessToken =
              refreshResponse.data['access_token'] as String?;

          if (newAccessToken != null) {
            await preferences.setToken(newAccessToken);

            // Relancer les requêtes en attente
            for (final request in _requestsQueue) {
              final options = request['options'] as RequestOptions;
              final retryHandler =
                  request['handler'] as ErrorInterceptorHandler;

              options.headers['Authorization'] = 'Bearer $newAccessToken';

              try {
                final retryResponse = await dio.request(
                  options.path,
                  options: Options(
                    method: options.method,
                    headers: options.headers,
                    responseType: options.responseType,
                    contentType: options.contentType,
                  ),
                  data: options.data,
                  queryParameters: options.queryParameters,
                );
                retryHandler.resolve(retryResponse);
              } catch (e) {
                if (e is DioException) {
                  retryHandler.next(e);
                } else {
                  retryHandler.next(err);
                }
              }
            }
            _requestsQueue.clear();

            // Relancer la requête courante
            err.requestOptions.headers['Authorization'] =
                'Bearer $newAccessToken';
            try {
              final currentRetry = await dio.request(
                err.requestOptions.path,
                options: Options(
                  method: err.requestOptions.method,
                  headers: err.requestOptions.headers,
                  responseType: err.requestOptions.responseType,
                  contentType: err.requestOptions.contentType,
                ),
                data: err.requestOptions.data,
                queryParameters: err.requestOptions.queryParameters,
              );
              _isRefreshing = false;
              return handler.resolve(currentRetry);
            } catch (e) {
              if (e is DioException) {
                _isRefreshing = false;
                return handler.next(e);
              }
            }
          }
        } catch (e) {
          _isRefreshing = false;
          _requestsQueue.clear();
          await preferences.forceLogout(
            'Votre session a expiré. Veuillez vous reconnecter.',
          );
          return handler.next(err);
        }
      } else {
        // C'est le endpoint de refresh qui a renvoyé 401
        await preferences.forceLogout(
          'Votre session a expiré. Veuillez vous reconnecter.',
        );
      }
    }

    _isRefreshing = false;
    return handler.next(err);
  }
}
