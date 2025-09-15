import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qpay/Events/transaction_success_event.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/net/contract/transaction_vm.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/static_data/app_event_bus.dart';
import 'package:qpay/widgets/load_image.dart';
import 'package:qpay/widgets/my_scroll_view.dart';
import 'package:qpay/widgets/transaction_account_selector.dart';
import 'package:share_plus/share_plus.dart';

class TransactionCompletedPage extends StatefulWidget {
  final TransactionAccountSelector? from;
  final TransactionAccountSelector? to;
  final TransactionViewModel? transaction;

  const TransactionCompletedPage(
    this.from,
    this.to,
    this.transaction, {
    Key? key,
  }) : super(key: key);

  @override
  State<TransactionCompletedPage> createState() =>
      _TransactionCompletedPageState();
}

class _TransactionCompletedPageState extends State<TransactionCompletedPage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  Uint8List? _imageFile;
  List<String> imagePaths = [];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size / 0.9;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: () async {
                      if (widget.transaction?.transactionName != null) {
                        await _share(
                          context,
                          widget.transaction!.transactionName!,
                        );
                      }
                    },
                    child: Icon(
                      Icons.share,
                      color: widget.transaction?.getTranSactionColor(),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: () {
                      if (widget.transaction?.isSuccessful() ?? false) {
                        AppEventManager().eventBus.fire(
                          TransactionSuccessEvent(
                            "transaction successful and call the event",
                          ),
                        );
                      }
                      _exit(context);
                    },
                    child: Icon(
                      Icons.home,
                      color: widget.transaction?.getTranSactionColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: MyScrollView(
            children: [
              RepaintBoundary(
                key: _repaintBoundaryKey,
                child: Container(
                  color: CupertinoColors.white,
                  height: size.height * 1.1,
                  child: Stack(
                    children: [
                      Container(
                        height: size.height * .4,
                        width: size.width,
                        color: widget.transaction?.getTranSactionColor(),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logo_white.png',
                                scale: 12,
                              ),
                              widget.transaction!.getTransactionIcon(),
                              Text(
                                widget.transaction?.transactionDetails ??
                                    AppLocalizations.of(context)!.notAvailable,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimens.font_sp20,
                                ),
                              ),
                              Text(
                                widget.transaction?.dateTime ??
                                    AppLocalizations.of(context)!.notAvailable,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: Dimens.font_sp14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * .38,
                        right: -(MediaQuery.of(context).size.width * .025),
                        child: Container(
                          width: size.width * .95,
                          color: CupertinoColors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                  ),
                                  elevation: 5.0,
                                  child: Container(
                                    color: CupertinoColors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget
                                                    .transaction!
                                                    .transactionName!,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: Dimens.font_sp16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 24),
                                          _viewParams(
                                            'TRANSACTION ID',
                                            widget.transaction!.transactionId ??
                                                AppLocalizations.of(
                                                  context,
                                                )!.notAvailable,
                                          ),
                                          SizedBox(height: 10),
                                          _viewParams(
                                            'AMOUNT',
                                            '৳ ' +
                                                (widget
                                                        .transaction!
                                                        .amountFormatted ??
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.notAvailable),
                                          ),
                                          SizedBox(height: 10),
                                          _viewParams(
                                            'TOTAL FEES',
                                            '৳ ' +
                                                (widget
                                                        .transaction!
                                                        .feeFormatted ??
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.notAvailable),
                                          ),
                                          SizedBox(height: 10),
                                          _viewParams(
                                            'TOTAL',
                                            '৳ ' +
                                                (widget.transaction?.total ??
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.notAvailable),
                                          ),
                                          SizedBox(height: 10),
                                          _viewParams(
                                            'PURPOSE',
                                            widget.transaction!.remarks ??
                                                AppLocalizations.of(
                                                  context,
                                                )!.notAvailable,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  elevation: 5.0,
                                  child: Container(
                                    color: CupertinoColors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 15),
                                          Card(
                                            elevation: 2.0,
                                            child: Container(
                                              color: CupertinoColors.white,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  4.0,
                                                ),
                                                child: widget.from,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          widget.to != null
                                              ? Card(
                                                  elevation: 2.0,
                                                  child: Container(
                                                    color:
                                                        CupertinoColors.white,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4.0,
                                                          ),
                                                      child: widget.to,
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(),
                                          SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _viewParams(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          softWrap: true,
          style: TextStyle(
            color: Colours.text_gray,
            fontSize: Dimens.font_sp14,
            fontWeight: FontWeight.normal,
          ),
        ),
        SelectableText(
          value,
          cursorColor: Colors.red,
          showCursor: false,
          contextMenuBuilder: (BuildContext context, EditableTextState state) {
            return AdaptiveTextSelectionToolbar.buttonItems(
              anchors: state.contextMenuAnchors,
              buttonItems: [
                ContextMenuButtonItem(
                  onPressed: () {
                    state.copySelection(SelectionChangedCause.toolbar);
                  },
                  type: ContextMenuButtonType.copy,
                ),
                ContextMenuButtonItem(
                  onPressed: () {
                    state.selectAll(SelectionChangedCause.toolbar);
                  },
                  type: ContextMenuButtonType.selectAll,
                ),
              ],
            );
          },
          style: TextStyle(
            color: Colours.text_gray,
            fontSize: Dimens.font_sp12,
            fontWeight: FontWeight.bold,
          ),
        ),

        /*  SelectableText(
          value,
          cursorColor: Colors.red,
          showCursor: false,
          toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
          style: TextStyle(
              color: Colours.text_gray,
              fontSize: Dimens.font_sp12,
              fontWeight: FontWeight.bold),
        ), */
      ],
    );
  }

  void _exit(BuildContext context) {
    NavigatorUtils.goBack(context);
  }

  Future<Uint8List?> _capturePng() async {
    try {
      final boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        return null;
      }
      final devicePixelRatio = View.of(context).devicePixelRatio;
      final image = await boundary.toImage(pixelRatio: devicePixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<void> _share(BuildContext context, String transactionName) async {
    final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;

    final status = sdkInt >= 33
        ? await Permission.photos.status
        : (sdkInt >= 30
              ? await Permission.manageExternalStorage.status
              : await Permission.storage.status);

    if (!status.isGranted) {
      final result = sdkInt >= 33
          ? await Permission.photos.request()
          : (sdkInt >= 30
                ? await Permission.manageExternalStorage.request()
                : await Permission.storage.request());
      if (!result.isGranted) {
        try {
          if (result.isPermanentlyDenied) {
            AppSettings.openAppSettings();
          } else {
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted) {
                showToast(
                  'Storage permission is required to share receipt',
                  backgroundColor: Colors.black,
                );
              }
            });
          }
        } catch (e) {}

        return;
      }
    }

    _imageFile = await _capturePng();
    if (_imageFile == null) {
      showToast('Failed to capture receipt image');
      return;
    }

    final now = DateTime.now();
    final dateFormat = DateFormat('dd-MM-yyyy_HH-mm');
    final dateTime = dateFormat.format(now);
    final fileName = '${transactionName}_$dateTime.png';

    try {
      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationSupportDirectory();

      if (directory == null) {
        showToast('Failed to access storage directory');
        return;
      }

      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(_imageFile!);

      /* await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Share Receipt of Transaction from QPay',
      ); */
      final params = ShareParams(
        text: 'Share Receipt of Transaction from QPay',
        files: [XFile(filePath)],
      );
      await SharePlus.instance.share(params);
    } catch (e) {
      showToast('Failed to share receipt');
    }
  }
}

/*
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qpay/Events/transaction_success_event.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/net/contract/transaction_vm.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/static_data/app_event_bus.dart';
import 'package:qpay/widgets/load_image.dart';
import 'package:qpay/widgets/my_scroll_view.dart';
import 'package:qpay/widgets/transaction_account_selector.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../widgets/app_bar.dart';


class TransactionCompletedPage extends StatelessWidget {
  final TransactionAccountSelector? from;
  final TransactionAccountSelector? to;
  final TransactionViewModel? transaction;
  TransactionCompletedPage(this.from, this.to, this.transaction);
  Uint8List? _imageFile;
  ScreenshotController screenshotController = ScreenshotController();
  List<String> imagePaths = [];
  final shareButtonGlobalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size/.9;
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(top:40.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 0.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed:() async{ _share(context,transaction!.transactionName!);},
                      child: Icon(Icons.share,color: transaction?.getTranSactionColor(),),),
                  ),
                ),
                Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: ()async{
                    if(transaction!.isSuccessful()){
                      AppEventManager().eventBus.fire(TransactionSuccessEvent("transaction successful and call the event"));
                    }
                    _exit(context);
                  },
                  child: Icon(Icons.home,color: transaction?.getTranSactionColor(),),),
              ),
            ),
              ],
            ),
          ),
          body: MyScrollView(
            children: [
              Screenshot(
                controller: screenshotController,
                child: Container(
                  color: CupertinoColors.white,
                  height: size.height*1.1,
                  child: Stack(
                    children: [
                      Container(
                        height: size.height *.4,
                        width: size.width,
                        color: transaction?.getTranSactionColor(),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/logo_white.png',scale: 12,),
                              transaction!.getTransactionIcon(),
                              Text(
                                transaction?.transactionDetails??AppLocalizations.of(context)!.notAvailable,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: Dimens.font_sp20),
                              ),
                              Text(
                                transaction?.dateTime??AppLocalizations.of(context)!.notAvailable,
                                style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal,fontSize: Dimens.font_sp14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top:MediaQuery.of(context).size.height*.38 ,
                        right: -(MediaQuery.of(context).size.width*.025),
                        child: Container(
                          width: size.width*.95,
                          color: CupertinoColors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8)),
                                  ),
                                  elevation: 5.0,
                                  child: Container(
                                    color: CupertinoColors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Gaps.vGap15,
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children:[
                                              Text(transaction!.transactionName!,style: TextStyle(color: Colors.black,fontSize: Dimens.font_sp16,fontWeight: FontWeight.bold),),
                                            ],
                                          ),
                                          Gaps.vGap24,
                                          _viewParams('TRANSACTION ID', transaction!.transactionId!??AppLocalizations.of(context)!.notAvailable),
                                          Gaps.vGap10,
                                          _viewParams('AMOUNT', '৳ '+transaction!.amountFormatted!  ??AppLocalizations.of(context)!.notAvailable),
                                          Gaps.vGap10,
                                          _viewParams('TOTAL FEES', '৳ '+transaction!.feeFormatted! ??AppLocalizations.of(context)!.notAvailable),
                                          Gaps.vGap10,
                                          _viewParams('TOTAL', '৳ '+transaction!.total ??AppLocalizations.of(context)!.notAvailable),
                                          Gaps.vGap10,
                                          _viewParams('PURPOSE', transaction!.remarks ??AppLocalizations.of(context)!.notAvailable),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8)),
                                  ),
                                  elevation: 5.0,
                                  child: Container(
                                    color: CupertinoColors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Gaps.vGap15,
                                          Card(
                                              elevation: 2.0,
                                              child: Container(
                                                color: CupertinoColors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: from,
                                                ),
                                              )),
                                          Gaps.vGap10,
                                          to!=null?Card(
                                              elevation: 2.0,
                                              child: Container(
                                                color: CupertinoColors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: to,
                                                ),
                                              )):SizedBox(),
                                          Gaps.vGap8,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                  ),
                ),
              ),
          ]
          ),
        ),
      ),
    );
  }

  void _exit(BuildContext context) {
    NavigatorUtils.goBack(context);
  }

  void _share(BuildContext context, String transactionName) async {
    var status = await Permission.storage.status;

    Future<void> captureAndShare() async {
      imagePaths.clear();
      _imageFile = null;

      final capturedImage = await screenshotController.capture(delay: const Duration(milliseconds: 10));
      if (capturedImage == null) return;

      _imageFile = capturedImage;

      final now = DateTime.now();
      final dateFormat = DateFormat('dd-MM-yyyy_hh:mm');
      final fileName = '${transactionName}_$dateFormat.png';

      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationSupportDirectory();

      final path = '${directory!.path}/$fileName';
      final file = File(path);
      await file.writeAsBytes(capturedImage);

      await Share.shareXFiles(
        [XFile(path)],
        text: 'Share Receipt of Transaction from QPay',
      );
    }

    if (status.isGranted) {
      await captureAndShare();
    } else if (status.isDenied) {
      final requested = await Permission.storage.request();
      if (requested.isGranted) {
        await captureAndShare();
      } else if (requested.isPermanentlyDenied) {
        AppSettings.openAppSettings();
      }
    } else if (status.isPermanentlyDenied) {
      AppSettings.openAppSettings();
    }
  }

 */
/* void _share(BuildContext context,String transactionName) async {
    var status = await Permission.storage.status;
    if (status==PermissionStatus.granted) {
      imagePaths.clear();
      _imageFile = null;
      screenshotController.capture(delay: Duration(milliseconds: 10))
          .then((Uint8List? captureImage) async {
        if (captureImage != null) {
          _imageFile = captureImage;
        }
        var now = DateTime.now();
        var dateFormat = DateFormat('dd-MM-yyyy hh:mm');
        var dateTime = dateFormat.format(now);
        var screenShotName = transactionName + '_' + dateTime;
        final directory = Platform.isAndroid
            ? await getExternalStorageDirectory() //FOR ANDROID
            : await getApplicationSupportDirectory();
        Uint8List pngBytes = _imageFile!.buffer.asUint8List();
        File imgFile = new File('$directory/$screenShotName.png');
        imagePaths.add(imgFile.path);
        imgFile.writeAsBytes(pngBytes);

        await ShareFilesAndScreenshotWidgets().shareFile(
            screenShotName, '$screenShotName.png', pngBytes, "image/png",
            text: 'Share Receipt of Transaction from QPay');
      }).catchError((onError) {

      });
    }
    if(status==PermissionStatus.denied){
      var requested =  await Permission.storage.request();
      if (requested==PermissionStatus.granted) {
        imagePaths.clear();
        _imageFile = null;
        screenshotController.capture(delay: Duration(milliseconds: 10))
            .then((Uint8List? captureImage) async {
          if (captureImage != null) {
            _imageFile = captureImage;
          }
          var now = DateTime.now();
          var dateFormat = DateFormat('dd-MM-yyyy hh:mm');
          var dateTime = dateFormat.format(now);
          var screenShotName = transactionName + '_' + dateTime;
          final directory = Platform.isAndroid
              ? await getExternalStorageDirectory() //FOR ANDROID
              : await getApplicationSupportDirectory();
          Uint8List pngBytes = _imageFile!.buffer.asUint8List();
          File imgFile = new File('$directory/$screenShotName.png');
          imagePaths.add(imgFile.path);
          imgFile.writeAsBytes(pngBytes);

       *//*
*/
/*   Platform.isAndroid ? await Share.shareFiles(imagePaths,
          subject: 'Share Receipt of Transaction from QPay',
          text: screenShotName,
          sharePositionOrigin:  box.localToGlobal(Offset.zero) & box.size)
          : *//*
*/
/*
          await ShareFilesAndScreenshotWidgets().shareFile(
              screenShotName, '$screenShotName.png', pngBytes, "image/png",
              text: 'Share Receipt of Transaction from QPay');
        }).catchError((onError) {

        });
      }
      if(requested == PermissionStatus.permanentlyDenied){
        status = requested;
      }
      }
    if(status == PermissionStatus.permanentlyDenied){
      AppSettings.openAppSettings();
    }
    }*//*

  }


  Widget _viewParams(String title, String value){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, softWrap: true ,style: TextStyle(color: Colours.text_gray,fontSize: Dimens.font_sp14,fontWeight: FontWeight.normal),),
        SelectableText(value, cursorColor: Colors.red, showCursor: false,
          toolbarOptions: ToolbarOptions(
              copy: true,
              selectAll: true,
              cut: false,
              paste: false
          ), style: TextStyle(color: Colours.text_gray,fontSize: Dimens.font_sp12,fontWeight: FontWeight.bold),),
      ],
    );
}
*/
