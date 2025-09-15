import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:qpay/common/appconstants.dart';
import 'package:qpay/mvp/base_page_presenter.dart';
import 'package:qpay/net/contract/api_basic_vm.dart';
import 'package:qpay/net/dio_utils.dart';
import 'package:qpay/net/http_api.dart';
import 'package:qpay/net/intercept.dart';
import 'package:qpay/views/settings/settings_iview.dart';

class SettingsPagePresenter extends BasePagePresenter<SettingsIMvpView> {
  Future<int?> rawApiDeleteCall() async {
    var accesstoken = await SpUtil.getString(Constant.accessToken);
    var response = await Dio().post(
      ApiEndpoint.deleteAccountRequest,
      options: Options(headers: {"Authorization": "Bearer $accesstoken"}),
    );

    return response.statusCode;
  }

  Future<int?> rawApiCancelCall() async {
    var accesstoken = await SpUtil.getString(Constant.accessToken);
    /**await di.post(ApiEndpoint.cancelDeleteAccountRequest); */
    var response = await Dio().post(
      ApiEndpoint.cancelDeleteAccountRequest,
      options: Options(headers: {"Authorization": "Bearer $accesstoken"}),
    );

    return response.statusCode;
  }

  Future<bool> accountDeleteRequest() async {
    bool success = false;
    try {
      await requestStatusOnly(
        Method.post,
        url: ApiEndpoint.deleteAccountRequest,
        queryParameters: null,
        options: null,
        onSuccess: (_) {
          success = true; // ✅ request succeeded based on status code
        },
        onError: (code, msg) {
          view.showSnackBar("Error ($code): $msg");
        },
      );
    } catch (e) {
      view.showSnackBar('Failed to send request!');
      view.closeProgress();
    }
    return success;
  }

  Future<bool> cancelAccountDeleteRequest() async {
    bool success = false;
    try {
      await requestStatusOnly(
        Method.post,
        url: ApiEndpoint.cancelDeleteAccountRequest,
        queryParameters: null,
        options: null,
        onSuccess: (_) {
          success = true; // ✅ request succeeded based on status code
        },
        onError: (code, msg) {
          view.showSnackBar("Error ($code): $msg");
        },
      );
    } catch (e) {
      view.showSnackBar('Failed to send request!');
      view.closeProgress();
    }
    return success;
  }
}
