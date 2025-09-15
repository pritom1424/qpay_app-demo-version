import 'package:dio/dio.dart';
import 'package:qpay/mvp/base_page_presenter.dart';
import 'package:qpay/net/contract/api_basic_vm.dart';
import 'package:qpay/net/dio_utils.dart';
import 'package:qpay/net/http_api.dart';
import 'package:qpay/views/home/profile/profile_veiw_iview.dart';

class ProfileViewPresenter extends BasePagePresenter<ProfileViewIMvpView> {
  Future<String?> uploadProfileImage(String profileImage) async {
    String? response;
    try {
      var profileImageName =
          profileImage.substring(profileImage.lastIndexOf('/') + 1);

      FormData formData = FormData.fromMap({
        'ProfileImage': await MultipartFile.fromFile(
          profileImage,
          filename: profileImageName,
        ),
      });

      print("before send -✅ Raw response data: $profileImage");

      await requestNetwork<Map<String, dynamic>>(
        Method.put,
        url: ApiEndpoint.profileImageUpdate,
        params: formData,
        onSuccess: (data) {
          print("✅ Raw response data: $data");
          print("imageUploadSuccess");
          var responseJson = Result.fromJson(data);
          print(
              "✅ Parsed response: ${responseJson.toString()}"); // if you have toJson()

          if (responseJson.isSuccess!) {
            response = responseJson.body;
          } else {
            print("❌ Server responded with failure flag");
          }
        },
      );
    } catch (e) {
      view.showSnackBar('Failed to get response!');
      view.closeProgress();
    }
    return response;
  }
}
