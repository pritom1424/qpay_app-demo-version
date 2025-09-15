import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'contract/base_entity.dart';
import 'error_handler.dart';

int _connectTimeout = 40000;
int _receiveTimeout = 40000;
int _sendTimeout = 10000;
String? _baseUrl;
String? _baseAuthUrl;
List<Interceptor> _interceptors = [];
int? unAuthStatus;

void setInitDio({
  int? connectTimeout,
  int? receiveTimeout,
  int? sendTimeout,
  List<Interceptor>? interceptors,
}) {
  _connectTimeout = connectTimeout ?? _connectTimeout;
  _receiveTimeout = receiveTimeout ?? _receiveTimeout;
  _sendTimeout = sendTimeout ?? _sendTimeout;
  _baseUrl = '';
  _baseAuthUrl = '';
  _interceptors = interceptors ?? _interceptors;
}

typedef NetSuccessCallback<T> = Function(T data);
typedef NetSuccessListCallback<T> = Function(List<T> data);
typedef NetErrorCallback = Function(int code, String msg);

class DioUtils {
  static final DioUtils _singleton = DioUtils._();

  static DioUtils get instance => DioUtils();

  factory DioUtils() => _singleton;

  static Dio? _dio;

  Dio? get dio => _dio;

  DioUtils._() {
    BaseOptions _options = BaseOptions(
      connectTimeout: Duration(milliseconds: _connectTimeout),
      receiveTimeout: Duration(milliseconds: _receiveTimeout),
      sendTimeout: Duration(milliseconds: _sendTimeout),
      responseType: ResponseType.plain,
      validateStatus: (status) {
        return true;
      },
      baseUrl: "",
    );
    _dio = Dio(_options);

    _interceptors.forEach((interceptor) {
      _dio?.interceptors.add(interceptor);
    });
  }

  Future<BaseEntity<T>?> _request<T>(
    String method,
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      final Response? response = await _dio?.request(
        url,
        data: data,
        queryParameters: queryParameters,
        options: _checkOptions(method, options ?? Options()),
        cancelToken: cancelToken,
      );
      Map<String, dynamic> _map = parseData(response?.data.toString() ?? '');
      return BaseEntity.fromJson(_map);
    } on DioException catch (e) {
      if (e.response != null) {
      } else {}
    } catch (e) {
      return BaseEntity(
        ExceptionHandler.parse_error,
        'Failed to parse response',
        null,
      );
    }
  }

  Future<BaseEntity<void>?> _requestStatusOnly(
    String method,
    String url, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      final Response? response = await _dio?.request(
        url,
        queryParameters: queryParameters,
        options: _checkOptions(method, options ?? Options()),
        cancelToken: cancelToken,
      );

      final int? statusCode = response?.statusCode;

      if (statusCode != null) {
        return BaseEntity(statusCode, "Request completed", null);
      } else {
        return BaseEntity(
          ExceptionHandler.parse_error,
          "No status code received",
          null,
        );
      }
    } /* on DioException catch (e) {
      return BaseEntity(
          e.response?.statusCode ?? ExceptionHandler.network_error,
          "Request failed",
          null);
    }  */ catch (e) {
      return BaseEntity(
        ExceptionHandler.parse_error,
        "Unexpected error occurred",
        null,
      );
    }
  }

  Future requestStatusOnly(
    Method method,
    String url, {
    NetSuccessCallback<void>? onSuccess,
    NetErrorCallback? onError,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) {
    String m = _getRequestMethod(method);
    return _requestStatusOnly(
      m,
      url,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ).then(
      (BaseEntity<void>? result) {
        if (result?.code != null &&
            result!.code! >= 200 &&
            result.code! < 300) {
          if (onSuccess != null) {
            onSuccess(null); // nothing to return except success
          }
        } else {
          _onError(result?.code, result?.message, onError ?? null);
        }
      },
      onError: (dynamic e) {
        _cancelLogPrint(e, url);
        final NetError error = ExceptionHandler.handleException(e);
        _onError(error.code, error.msg, onError ?? null);
      },
    );
  }

  Future<BaseEntity<T>?> _requestEncoded<T>(
    String method,
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      final Response? response = await _dio?.request(
        url,
        data: data,
        queryParameters: queryParameters,
        options: _checkOptions(
          method,
          options ?? Options(),
          Headers.formUrlEncodedContentType,
        ), //_checkOptions(method, options??Options(method: method,sendTimeout: Duration(milliseconds: _sendTimeout),receiveTimeout: Duration(milliseconds:_receiveTimeout)), Headers.formUrlEncodedContentType),
        cancelToken: cancelToken,
      );

      Map<String, dynamic> _map = parseData(response?.data.toString() ?? '');
      return BaseEntity.fromJson(_map);
    } on DioException catch (e) {
      if (e.response != null) {
      } else {}
    } catch (e) {
      return BaseEntity(
        ExceptionHandler.parse_error,
        'Failed to parse response',
        null,
      );
    }
  }

  Options _checkOptions(String method, Options options, [String? contentType]) {
    options ??= Options();
    options.method = method;
    options.receiveDataWhenStatusError = true;

    if (contentType != null) {
      options.contentType = contentType.isNotEmpty
          ? contentType
          : options.contentType;
    }

    return options;
  }

  Future requestNetwork<T>(
    Method method,
    String url, {
    NetSuccessCallback<T>? onSuccess,
    NetSuccessListCallback<T>? onSuccessList,
    NetErrorCallback? onError,
    dynamic params,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    bool isList = false,
  }) {
    String m = _getRequestMethod(method);
    return _request<T>(
      m,
      url,
      data: params,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ).then(
      (BaseEntity<T>? result) {
        if (result?.code == 0) {
          if (isList) {
            if (onSuccessList != null) {
              onSuccessList(result?.listData as List<T>);
            }
          } else {
            if (onSuccess != null) {
              onSuccess(result?.data as T);
            }
          }
        } else {
          _onError(result?.code, result?.message, onError ?? null);
        }
      },
      onError: (dynamic e) {
        _cancelLogPrint(e, url);
        final NetError error = ExceptionHandler.handleException(e);
        _onError(error.code, error.msg, onError ?? null);
      },
    );
  }

  Future requestEncryptedNetwork<T>(
    Method method,
    String url, {
    NetSuccessCallback<T>? onSuccess,
    NetSuccessListCallback<T>? onSuccessList,
    NetErrorCallback? onError,
    dynamic params,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    bool isList = false,
  }) {
    String m = _getRequestMethod(method);
    return _requestEncoded<T>(
      m,
      url,
      data: params,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    ).then(
      (BaseEntity<T>? result) {
        if (result?.code == 0) {
          if (isList) {
            if (onSuccessList != null) {
              onSuccessList(result?.listData as List<T>);
            }
          } else {
            if (onSuccess != null) {
              onSuccess(result?.data as T);
            }
          }
        } else {
          _onError(result?.code, result?.message, onError);
        }
      },
      onError: (dynamic e) {
        _cancelLogPrint(e, url);
        final NetError error = ExceptionHandler.handleException(e);
        _onError(error.code, error.msg, onError);
      },
    );
  }

  void asyncRequestNetwork<T>(
    Method method,
    String url, {
    NetSuccessCallback<T>? onSuccess,
    NetSuccessListCallback<T>? onSuccessList,
    NetErrorCallback? onError,
    dynamic params,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    bool isList = false,
  }) {
    String m = _getRequestMethod(method);
    Stream.fromFuture(
      _request<T>(
        m,
        url,
        data: params,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    ).asBroadcastStream().listen(
      (result) {
        if (result?.code == 0) {
          if (isList) {
            if (onSuccessList != null) {
              onSuccessList(result?.listData as List<T>);
            }
          } else {
            if (onSuccess != null) {
              onSuccess(result?.data as T);
            }
          }
        } else {
          _onError(result?.code, result?.message, onError);
        }
      },
      onError: (dynamic e) {
        _cancelLogPrint(e, url);
        final NetError error = ExceptionHandler.handleException(e);
        _onError(error.code, error.msg, onError);
      },
    );
  }

  void _cancelLogPrint(dynamic e, String url) {
    if (e is DioException && CancelToken.isCancel(e)) {}
  }

  void _onError(int? code, String? msg, NetErrorCallback? onError) {
    onError!(code ?? 0, msg ?? '');
  }

  String _getRequestMethod(Method method) {
    String m;
    switch (method) {
      case Method.get:
        m = 'GET';
        break;
      case Method.post:
        m = 'POST';
        break;
      case Method.put:
        m = 'PUT';
        break;
      case Method.patch:
        m = 'PATCH';
        break;
      case Method.delete:
        m = 'DELETE';
        break;
      case Method.head:
        m = 'HEAD';
        break;
    }
    return m;
  }
}

Map<String, dynamic> parseData(String data) {
  return json.decode(data);
}

enum Method { get, post, put, patch, delete, head }
