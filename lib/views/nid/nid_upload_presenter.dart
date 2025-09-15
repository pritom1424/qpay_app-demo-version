import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:qpay/mvp/base_page_presenter.dart';
import 'package:qpay/net/contract/api_basic_vm.dart';
import 'package:qpay/net/contract/nid_information_parse_vm.dart';
import 'package:qpay/net/contract/nid_update_dto.dart';
import 'package:qpay/net/dio_utils.dart';
import 'package:qpay/net/http_api.dart';
import 'package:qpay/views/nid/nid_iview.dart';

class NidUploadPresenter extends BasePagePresenter<NidIMvpView> {
  Future<NidInformationParseViewModel?> uploadNid(NidUpdateDto nidData) async {
    NidInformationParseViewModel? response;

    try {
      print("enter");
      var nidFrontName = nidData.nidFrontPath.substring(
        nidData.nidFrontPath.lastIndexOf('/') + 1,
      );
      var nidBankName = nidData.nidBackPath.substring(
        nidData.nidBackPath.lastIndexOf('/') + 1,
      );

      FormData formData = FormData.fromMap({
        /*'NidNumber': nidData.nidNumber,*/
        'NidFront': await MultipartFile.fromFile(
          nidData.nidFrontPath,
          filename: nidFrontName,
        ),
        'NidBack': await MultipartFile.fromFile(
          nidData.nidBackPath,
          filename: nidBankName,
        ),
      });
      File frontFile = File(nidData.nidFrontPath);
      File backFile = File(nidData.nidBackPath);

      if (!frontFile.existsSync()) {
        print("❌ Front file does NOT exist: ${nidData.nidFrontPath}");
      }

      if (!backFile.existsSync()) {
        print("❌ Back file does NOT exist: ${nidData.nidBackPath}");
      }

      print(
        "front path presenter: ${nidData.nidFrontPath} file name${nidFrontName[nidFrontName.length - 1]}",
      );
      print(
        "back path presenter: ${nidData.nidBackPath}file name${nidBankName}",
      );

      formData.fields.forEach((f) => print("Field: ${f.key} = ${f.value}"));
      formData.files.forEach(
        (f) => print("File: ${f.key} = ${f.value.filename}"),
      );
      await requestNetwork<Map<String, dynamic>>(
        Method.post,
        url: ApiEndpoint.nidUpdate,
        params: formData,
        onSuccess: (data) {
          var responseJson = data["body"];
          response = NidInformationParseViewModel.fromJson(responseJson);
        },
      );
    } catch (e) {
      view.showSnackBar('Failed to get response!');
      view.closeProgress();
    }
    return response;
  }
}
