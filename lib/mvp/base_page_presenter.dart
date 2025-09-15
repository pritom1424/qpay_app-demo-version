import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:qpay/common/appconstants.dart';
import 'package:qpay/net/contract/base_entity.dart';
import 'package:qpay/net/dio_utils.dart';
import 'package:qpay/net/error_handler.dart';
import 'package:qpay/net/http_api.dart';
import 'base_presenter.dart';

import 'mvps.dart';

class BasePagePresenter<V extends IMvpView> extends BasePresenter<V> {
  CancelToken? _cancelToken;
  bool _connectionStatus = false;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  BasePagePresenter() {
    _cancelToken = CancelToken();
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (!_cancelToken!.isCancelled) {
      _cancelToken?.cancel();
    }
  }

  Future requestNetwork<T>(
    Method method, {
    required String url,
    bool isShow = true,
    bool isClose = true,
    NetSuccessCallback<T>? onSuccess,
    NetSuccessListCallback<T>? onSuccessList,
    NetErrorCallback? onError,
    dynamic params,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    bool isList = false,
  }) {
    if (isShow) view.showProgress();
    return DioUtils.instance.requestNetwork<T>(
      method,
      url,
      params: params,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
      isList: isList,
      onSuccess: (data) {
        if (isClose) view.closeProgress();
        if (onSuccess != null) {
          onSuccess(data);
        }
      },
      onSuccessList: (data) {
        if (isClose) view.closeProgress();
        if (onSuccessList != null) {
          onSuccessList(data);
        }
      },
      onError: (code, msg) {
        view.closeProgress();
        _onError(code, msg, onError ?? null);
      },
    );
  }

  Future requestUsingEncryptedNetwork<T>(
    Method method, {
    required String url,
    bool isShow = true,
    bool isClose = true,
    NetSuccessCallback<T>? onSuccess,
    NetSuccessListCallback<T>? onSuccessList,
    NetErrorCallback? onError,
    dynamic params,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    bool isList = false,
  }) {
    if (isShow) view.showProgress();
    return DioUtils.instance.requestEncryptedNetwork<T>(
      method,
      url,
      params: params,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
      isList: isList,
      onSuccess: (data) {
        if (isClose) view.closeProgress();
        if (onSuccess != null) {
          onSuccess(data);
        }
      },
      onSuccessList: (data) {
        if (isClose) view.closeProgress();
        if (onSuccessList != null) {
          onSuccessList(data);
        }
      },
      onError: (code, msg) {
        view.closeProgress();
        _onError(code, msg, onError ?? null);
      },
    );
  }

  Future<void> asyncRequestNetwork<T>(
    Method method, {
    required String url,
    bool isShow = true,
    bool isClose = true,
    NetSuccessCallback<T>? onSuccess,
    NetSuccessListCallback<T>? onSuccessList,
    NetErrorCallback? onError,
    dynamic params,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    bool isList = false,
  }) async {
    if (isShow) view.showProgress();
    DioUtils.instance.asyncRequestNetwork<T>(
      method,
      url,
      params: params,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
      isList: isList,
      onSuccess: (data) {
        if (isClose) view.closeProgress();
        if (onSuccess != null) {
          onSuccess(data);
        }
      },
      onSuccessList: (data) {
        if (isClose) view.closeProgress();
        if (onSuccessList != null) {
          onSuccessList(data);
        }
      },
      onError: (code, msg) {
        view.closeProgress();
        _onError(code, msg, onError ?? null);
      },
    );
  }

  Future requestStatusOnly(
    Method method, {
    required String url,
    bool isShow = true,
    bool isClose = true,
    NetSuccessCallback<void>? onSuccess,
    NetErrorCallback? onError,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) {
    if (isShow) view.showProgress();

    return DioUtils.instance.requestStatusOnly(
      method,
      url,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
      onSuccess: (_) {
        if (isClose) view.closeProgress();
        if (onSuccess != null) {
          onSuccess(null); // just signal success, no body
        }
      },
      onError: (code, msg) {
        view.closeProgress();
        _onError(code, msg, onError ?? null);
      },
    );
  }

  void _onError(int? code, String? msg, NetErrorCallback? onError) {
    view.closeProgress();
    try {
      check().then((internet) {
        if (internet) {
          if (code != ExceptionHandler.cancel_error) {
            if (code == ExceptionHandler.unknown_error) {
              view.showSnackBar('Please try again');
            } else {
              view.showSnackBar(msg ?? 'Please try again');
            }
          }
        } else {
          view.showSnackBar('Please check your internet connection');
        }
      });
    } catch (e) {}

    if (onError != null && view.getContext() != null) {
      onError(code ?? 0, msg ?? '');
    }
  }

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }

    return false;
  }
}
