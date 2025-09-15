import 'dart:collection';
import 'dart:convert';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/export.dart';
import 'package:qpay/Events/token_expire_event.dart';
import 'package:qpay/Events/token_refresh_event.dart';
import 'package:qpay/common/appconstants.dart';
import 'package:qpay/services/secure_key_manager.dart';
import 'package:qpay/static_data/app_event_bus.dart';
import 'package:qpay/utils/log_utils.dart';
import 'package:qpay/utils/rsa_utils.dart';
import 'package:sprintf/sprintf.dart';

import 'error_handler.dart';
import 'http_api.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler requestInterceptorHandler,
  ) async {
    /*We don't want execute this code if the path contains any request for token*/
    if (options.path != ApiEndpoint.token) {
      final String? accessToken = SpUtil.getString(Constant.accessToken);
      try {
        var accessTokenExpiryObj = SpUtil.getString(Constant.accessTokenExpiry);
        DateTime accessTokenExpiry = accessTokenExpiryObj == ""
            ? DateTime.now().add(new Duration(days: 30))
            : DateTime.parse(accessTokenExpiryObj!);
        DateTime expirationLimit = DateTime.now().add(new Duration(minutes: 2));
        var currentTime = DateTime.now();

        if (accessTokenExpiry.isBefore(expirationLimit) &&
            !currentTime.isAfter(accessTokenExpiry)) {
          AppEventManager().eventBus.fire(TokenRefreshEvent("token refresh"));
        }
      } catch (e) {
        e.toString();
      }

      if (accessToken!.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    requestInterceptorHandler.next(options);
  }
}

class TokenInterceptor extends Interceptor {
  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler responseInterceptorHandler,
  ) async {
    if (response.statusCode == ExceptionHandler.unauthorized) {
      AppEventManager().eventBus.fire(TokenExpireEvent("token Expired"));
    }
    responseInterceptorHandler.next(response);
  }
}

class LoggingInterceptor extends Interceptor {
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler interceptorHandler,
  ) {
    _startTime = DateTime.now();
    Log.d('----------Start----------');
    if (options.queryParameters.isEmpty) {
      Log.d('RequestUrl: ' + options.baseUrl + options.path);
    } else {
      Log.d(
        'RequestUrl: ' +
            options.baseUrl +
            options.path +
            '?' +
            Transformer.urlEncodeMap(options.queryParameters),
      );
    }
    Log.d('RequestMethod: ' + options.method);
    Log.d('RequestHeaders:' + options.headers.toString());
    Log.d('RequestContentType: ${options.contentType}');
    interceptorHandler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler responseInterceptorHandler,
  ) {
    _endTime = DateTime.now();
    int? duration = _endTime?.difference(_startTime!).inMilliseconds;
    if (response.statusCode == ExceptionHandler.success) {
      Log.d('ResponseCode: ${response.statusCode}');
    } else {
      Log.e('ResponseCode: ${response.statusCode}');
    }
    Log.d('----------End: $duration ----------');
    responseInterceptorHandler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler errorInterceptorHandler) {
    Log.d(err.message!);
    errorInterceptorHandler.next(err);
  }
}

class AdapterInterceptor extends Interceptor {
  static const String _kMsg = 'msg';
  static const String _kErrorMsg = 'errorMessage';
  static const String _kErrorMsgList = 'errors';
  static const String _kSlash = '\'';
  static const String _kMessage = 'message';
  static const String _kMessageUpper = 'Message';

  static const String _kDefaultText = '\"No Data\"';
  static const String _kNotFound = 'Not found';

  static const String _kFailureFormat = '{\"code\":%d,\"message\":\"%s\"}';
  static const String _kSuccessFormat =
      '{\"code\":0,\"data\":%s,\"message\":\"\"}';

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler responseInterceptorHandler,
  ) {
    Response? r = adapterData(response);
    responseInterceptorHandler.next(r!);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler errorInterceptorHandler) {
    if (err.response != null) {
      adapterData(err.response);
    }
    errorInterceptorHandler.next(err);
  }

  Response? adapterData(Response? response) {
    String result;
    String? content = response?.data == null ? '' : response?.data.toString();
    if (response?.statusCode == ExceptionHandler.success ||
        response?.statusCode == ExceptionHandler.success_not_content) {
      if (content!.isEmpty) {
        content = _kDefaultText;
      }
      result = sprintf(_kSuccessFormat, [content]);
      response?.statusCode = response.statusCode;
    } else {
      if (response?.statusCode == ExceptionHandler.not_found) {
        result = sprintf(_kFailureFormat, [response?.statusCode, _kNotFound]);
        response?.statusCode = ExceptionHandler.success;
      } else {
        if (content!.isEmpty) {
          result = content;
        } else {
          String? msg;
          try {
            content = content.replaceAll("\\", '');
            if (_kSlash == content.substring(0, 1)) {
              content = content.substring(1, content.length - 1);
            }
            msg = extractMessage(content, msg, response?.statusCode);
            result = sprintf(_kFailureFormat, [response?.statusCode, msg]);
            if (response?.statusCode == ExceptionHandler.unauthorized) {
              response?.statusCode = ExceptionHandler.unauthorized;
            } else {
              response?.statusCode = ExceptionHandler.success;
            }
          } catch (e) {
            Log.d('Error: $e');
            result = sprintf(_kFailureFormat, [
              response?.statusCode,
              'Unexpected error(${response?.statusCode})',
            ]);
          }
        }
      }
    }
    response?.data = result;
    return response;
  }

  String? extractMessage(String? content, String? msg, int? statusCode) {
    Map<String, dynamic> map = json.decode(content!);
    if (statusCode == ExceptionHandler.server_failure) {
      msg = "Unexpected error";
    } else if (map.containsKey(_kMessage)) {
      msg = map[_kMessage];
    } else if (map.containsKey(_kMsg)) {
      msg = map[_kMsg];
    } else if (map.containsKey(_kErrorMsg)) {
      msg = map[_kErrorMsg];
    } else if (map.containsKey(_kMessageUpper)) {
      msg = map[_kMessageUpper];
    } else if (map.containsKey(_kErrorMsgList)) {
      LinkedHashMap internalMap = map[_kErrorMsgList];
      msg = internalMap.values.first[0];
    } else {
      msg = 'Request Error!!';
    }
    return msg;
  }
}

class RsaSecurityInterceptor extends Interceptor {
  late final RSAPublicKey _serverPublicKey;

  late final Encrypter _encrypter;

  final String? serverPublicPem;

  RsaSecurityInterceptor({
    this.serverPublicPem,
    /*  this.clientPrivatePem */
  });

  Future<void> init() async {
    var publicPemUtf8 = const String.fromEnvironment(Constant.rsaEnvKey);
    var publicPem = utf8.decode(base64.decode(publicPemUtf8));

    await SecureKeyManager.writeValue(
      Constant.rsaPublicKey,
      publicPem,
    ); //Constant.rsaPublicKey1
    var sPublicPem = await SecureKeyManager.readValue(Constant.rsaPublicKey);

    final serverPem = serverPublicPem ?? sPublicPem;

    _serverPublicKey = RSAKeyParser().parse(serverPem!) as RSAPublicKey;

    _encrypter = Encrypter(
      RSA(publicKey: _serverPublicKey, encoding: RSAEncoding.PKCS1),
    );
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      Map<String, dynamic> dataMap = {};

      String otpFieldName = 'Otp';
      String trackingIdFieldName = 'TrackingId';
      String transactionIdFieldName = 'TransactionId';

      FormData? originalFormData;

      if (options.data is Map<String, dynamic>) {
        dataMap = Map<String, dynamic>.from(options.data);
      } else if (options.data is FormData) {
        originalFormData = options.data as FormData;
        for (var entry in originalFormData.fields) {
          dataMap[entry.key] = entry.value;
        }
      } else {
        handler.next(options);
        return;
      }
      if (dataMap.containsKey(otpFieldName)) {
        dataMap[otpFieldName] = _encrypter
            .encrypt(dataMap[otpFieldName].toString())
            .base64;
      }
      if (dataMap.containsKey(trackingIdFieldName)) {
        dataMap[trackingIdFieldName] = _encrypter
            .encrypt(dataMap[trackingIdFieldName].toString())
            .base64;
      }
      if (dataMap.containsKey(transactionIdFieldName)) {
        dataMap[transactionIdFieldName] = _encrypter
            .encrypt(dataMap[transactionIdFieldName].toString())
            .base64;
      }
      if (originalFormData != null) {
        final newFormData = FormData();
        dataMap.forEach((key, value) {
          newFormData.fields.add(MapEntry(key, value.toString()));
        });
        for (var file in originalFormData.files) {
          newFormData.files.add(file);
        }

        options.data = newFormData;
      } else {
        options.data = dataMap;
      }
    } catch (e) {}

    handler.next(options);
  }
}
