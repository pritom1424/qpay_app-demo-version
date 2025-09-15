import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qpay/Events/transaction_success_event.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/net/contract/bill_vendor_vm.dart';
import 'package:qpay/net/contract/transaction_vm.dart';
import 'package:qpay/res/gaps.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/static_data/app_event_bus.dart';
import 'package:qpay/widgets/load_image.dart';
import 'package:qpay/widgets/my_scroll_view.dart';
import 'package:qpay/widgets/transaction_account_selector.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/utils.dart';
import '../../widgets/my_dialog.dart';

class BillReceiptPage extends StatefulWidget {
  final TransactionViewModel? _transaction;
  final BillVendorViewModel _billVendorViewModel;
  final String? _subscriberAccountNumber;
  final String? _billMonthYear;
  final TransactionAccountSelector from;

  BillReceiptPage(
    this._transaction,
    this._billVendorViewModel,
    this._subscriberAccountNumber,
    this._billMonthYear,
    this.from, {
    Key? key,
  }) : super(key: key);

  @override
  State<BillReceiptPage> createState() => _BillReceiptPageState();
}

class _BillReceiptPageState extends State<BillReceiptPage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  Uint8List? _imageFile;

  List<String> imagePaths = [];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 0.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () async {
                        await _share(
                          context,
                          widget._transaction?.transactionName ?? '',
                        );
                      },
                      child: Icon(
                        Icons.share,
                        color: widget._transaction?.getTranSactionColor(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () async {
                        if (widget._transaction?.isSuccessful() ?? false) {
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
                        color: widget._transaction?.getTranSactionColor(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: MyScrollView(
            children: [
              Container(
                color: Colors.white,
                child: RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: Container(
                    height: size.height * 1.15,
                    color: CupertinoColors.white,
                    child: Stack(
                      children: [
                        Container(
                          height: size.height * .4,
                          width: size.width,
                          color: widget._transaction?.getTranSactionColor(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logo_white.png',
                                scale: 10,
                              ),
                              widget._transaction?.getTransactionIcon() ??
                                  LoadAssetImage("tr_pending", width: 48.0),
                              Text(
                                widget._transaction?.transactionStatus ??
                                    AppLocalizations.of(context)!.notAvailable,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimens.font_sp20,
                                ),
                              ),
                              Text(
                                widget._transaction?.dateTime ??
                                    AppLocalizations.of(context)!.notAvailable,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: Dimens.font_sp14,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Card(
                                      elevation: 5.0,
                                      child: Image(
                                        image: NetworkImage(
                                          widget._billVendorViewModel.imageUrl!,
                                          scale: 15,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Receipt',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * .38,
                          right: -(MediaQuery.of(context).size.width * .025),
                          child: Container(
                            width: size.width,
                            color: CupertinoColors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    ),
                                    elevation: 5.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Bill Information',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: Dimens.font_sp16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Gaps.vGap8,
                                          _viewParams(
                                            'Transaction ID',
                                            widget
                                                    ._transaction
                                                    ?.transactionId ??
                                                AppLocalizations.of(
                                                  context,
                                                )!.notAvailable,
                                          ),
                                          Gaps.vGap8,
                                          _viewParams(
                                            'Service',
                                            widget._billVendorViewModel.name ??
                                                AppLocalizations.of(
                                                  context,
                                                )!.notAvailable,
                                          ),
                                          Gaps.vGap8,
                                          _viewParams(
                                            'Bill Month',
                                            widget._billMonthYear ??
                                                AppLocalizations.of(
                                                  context,
                                                )!.notAvailable,
                                          ),
                                          Gaps.vGap8,
                                          _viewParams(
                                            'Credited To',
                                            widget._subscriberAccountNumber ??
                                                AppLocalizations.of(
                                                  context,
                                                )!.notAvailable,
                                          ),
                                          Gaps.vGap8,
                                          _viewParams(
                                            'Amount',
                                            '৳ ${widget._transaction?.amountFormatted ?? AppLocalizations.of(context)!.notAvailable}',
                                          ),
                                          Gaps.vGap10,
                                          _viewParams(
                                            'Total Fees',
                                            '৳ ${widget._transaction?.feeFormatted ?? AppLocalizations.of(context)!.notAvailable}',
                                          ),
                                          Gaps.vGap10,
                                          _viewParams(
                                            'Total',
                                            '৳ ${widget._transaction?.total ?? AppLocalizations.of(context)!.notAvailable}',
                                          ),
                                          Gaps.vGap10,
                                          _viewParams(
                                            'Purpose',
                                            widget._transaction?.remarks ??
                                                AppLocalizations.of(
                                                  context,
                                                )!.notAvailable,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    elevation: 5.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Gaps.vGap15,
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
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exit(BuildContext context) {
    NavigatorUtils.goBack(context);
  }

  Future<void> _save(String title, String transactionName) async {
    try {
      _imageFile = await _capturePng();
      if (_imageFile == null) {
        showToast('Failed to capture receipt image');
        return;
      }
      var now = DateTime.now();
      var dateFormat = DateFormat('dd-MM-yyyy hh:mm');
      var dateTime = dateFormat.format(now);
      var screenShotName = transactionName + '_' + dateTime;
      final directory = (await getExternalStorageDirectory())!.path;

      final imgFile = File('$directory/$screenShotName.png');
      imagePaths.add(imgFile.path);
      await imgFile.writeAsBytes(_imageFile!);
      showToast(
        'Receipt Saved to Storage',
        backgroundColor: Colors.black.withValues(alpha: (0.4 * 255)),
      );
      /* Colors.black.withOpacity(0.4)); */
    } catch (e) {
      showToast('Error saving receipt');
    }
  }

  Future<void> _share(BuildContext context, String transactionName) async {
    final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;

    var status = sdkInt >= 33
        ? await Permission.photos.status
        : (sdkInt >= 30
              ? await Permission.manageExternalStorage.status
              : await Permission.storage.status);
    if (status != PermissionStatus.granted) {
      status = sdkInt >= 33
          ? await Permission.photos.request()
          : (sdkInt >= 30
                ? await Permission.manageExternalStorage.request()
                : await Permission.storage.request());
    }

    if (status == PermissionStatus.granted) {
      try {
        _imageFile = await _capturePng();
        if (_imageFile == null) {
          showToast('Failed to capture receipt image');
          return;
        }
        var now = DateTime.now();
        var dateFormat = DateFormat('dd-MM-yyyy hh:mm');
        var dateTime = dateFormat.format(now);
        var screenShotName = transactionName + '_' + dateTime;

        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          showToast('Failed to access storage directory');
          return;
        }

        final filePath = '${directory.path}/$screenShotName.png';
        final imgFile = File(filePath);

        await imgFile.writeAsBytes(_imageFile!);
        imagePaths.add(imgFile.path);
        final params = ShareParams(
          text: 'Share Receipt of Transaction from QPay',
          files: [XFile(imgFile.path)],
        );
        await SharePlus.instance.share(params);
        /* await Share.shareXFiles(
          [XFile(imgFile.path)],
          text: 'Share Receipt of Transaction from QPay',
        ); */
      } catch (e) {
        showToast('Failed to share receipt');
      }
    } else if (status == PermissionStatus.permanentlyDenied) {
      AppSettings.openAppSettings();
    } else {
      showToast('Storage permission is required to share receipt');
    }
  }

  Future<Uint8List?> _capturePng() async {
    try {
      final boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        return null;
      }

      final devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
      final image = await boundary.toImage(pixelRatio: devicePixelRatio);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
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
        Text(
          value,
          softWrap: true,
          style: TextStyle(
            color: Colours.text_gray,
            fontSize: Dimens.font_sp12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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
import 'package:oktoast/oktoast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qpay/Events/transaction_success_event.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/net/contract/bill_vendor_vm.dart';
import 'package:qpay/net/contract/transaction_vm.dart';
import 'package:qpay/res/gaps.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/static_data/app_event_bus.dart';
import 'package:qpay/widgets/load_image.dart';
import 'package:qpay/widgets/my_scroll_view.dart';
import 'package:qpay/widgets/transaction_account_selector.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/utils.dart';
import '../../widgets/my_dialog.dart';


class BillReceiptPage extends StatelessWidget {
  final TransactionViewModel? _transaction;
  final BillVendorViewModel _billVendorViewModel;
  final String _subscriberAccountNumber;
  final String _billMonthYear;
  final TransactionAccountSelector from;
  BillReceiptPage(this._transaction, this._billVendorViewModel, this._subscriberAccountNumber, this._billMonthYear, this.from);
  Uint8List? _imageFile;
  ScreenshotController screenshotController = ScreenshotController();
  List<String> imagePaths = [];
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
          child: Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
            floatingActionButton: Padding(
              padding:  const EdgeInsets.only(top:40.0),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 0.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed:() async{ _share(context,_transaction?.transactionName??'');},
                        child: Icon(Icons.share,color: _transaction?.getTranSactionColor(),),),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: ()async{
                          if(_transaction?.isSuccessful()??false){
                            AppEventManager().eventBus.fire(TransactionSuccessEvent("transaction successful and call the event"));
                          }
                          _exit(context);
                        },
                        child: Icon(Icons.home,color: _transaction?.getTranSactionColor(),),),
                    ),
                  ),
                ],
              ),
            ),
            body: MyScrollView(
              children:[
                Container(
                  color: Colors.white,
                  child: Screenshot(
                    controller: screenshotController,
                    child: Container(
                      height: size.height*1.15,
                      color: CupertinoColors.white,
                      child: Stack(
                        children: [
                          Container(
                            height: size.height *.4,
                            width: size.width,
                            color: _transaction?.getTranSactionColor(),
                            child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/logo_white.png',scale: 10,),
                              _transaction?.getTransactionIcon()??LoadAssetImage("tr_pending", width: 48.0),
                              Text(
                                _transaction?.transactionStatus??AppLocalizations.of(context)!.notAvailable,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: Dimens.font_sp20),
                              ),
                              Text(
                                _transaction?.dateTime??AppLocalizations.of(context)!.notAvailable,
                                style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal,fontSize: Dimens.font_sp14),
                              ),
                              Padding(
                               padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   Card(
                                     elevation: 5.0,
                                     child: Image(
                                       image: NetworkImage(_billVendorViewModel.imageUrl!,scale: 15),
                                     ),
                                   ),
                                   Text('Receipt',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white),),
                                 ],
                               ),
                             ),

                            ],
                        ),
                          ),
                          Positioned(
                              top:MediaQuery.of(context).size.height*.38 ,
                              right: -(MediaQuery.of(context).size.width*.025),
                              child: Container(
                                width: size.width,
                                color: CupertinoColors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8)),
                                        ),
                                        elevation: 5.0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Bill Information',style: TextStyle(color: Colors.black,fontSize: Dimens.font_sp16,fontWeight: FontWeight.bold),),
                                                ],
                                              ),
                                              Gaps.vGap8,
                                              _viewParams('Transaction ID',_transaction?.transactionId??AppLocalizations.of(context)!.notAvailable),
                                              Gaps.vGap8,
                                              _viewParams('Service',_billVendorViewModel.name??AppLocalizations.of(context)!.notAvailable),
                                              Gaps.vGap8,
                                              _viewParams('Bill Month',_billMonthYear??AppLocalizations.of(context)!.notAvailable),
                                              Gaps.vGap8,
                                              _viewParams('Credited To',_subscriberAccountNumber??AppLocalizations.of(context)!.notAvailable),
                                              Gaps.vGap8,
                                              _viewParams('Amount','৳ ${_transaction?.amountFormatted??AppLocalizations.of(context)!.notAvailable}'),
                                              Gaps.vGap10,
                                              _viewParams('Total Fees', '৳ ${_transaction?.feeFormatted ??AppLocalizations.of(context)!.notAvailable}'),
                                              Gaps.vGap10,
                                              _viewParams('Total', '৳ ${_transaction?.total ??AppLocalizations.of(context)!.notAvailable}'),
                                              Gaps.vGap10,
                                              _viewParams('Purpose', _transaction?.remarks??AppLocalizations.of(context)!.notAvailable),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8)),
                                        ),
                                        elevation: 5.0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                      ],
                      ),
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

  _save(String title, String transactionName) async {
    _imageFile = null;
    screenshotController.capture(
        delay: Duration(milliseconds: 10),pixelRatio: 1.0)
        .then((Uint8List? capturedImage) async {
      if(capturedImage != null) {
        _imageFile = capturedImage;
      }
      var now = DateTime.now();
      var dateFormat = DateFormat('dd-MM-yyyy hh:mm');
      var dateTime = dateFormat.format(now);
      var screenShotName= transactionName+'_'+dateTime;
      final directory = (await getExternalStorageDirectory())!.path;
      Uint8List pngBytes = _imageFile!.buffer.asUint8List();
      File imgFile = new File('$directory/$screenShotName.png');
      imagePaths.add(imgFile.path);
      imgFile.writeAsBytes(pngBytes).then((value){
        showToast('Receipt Saved to Storage',
            backgroundColor: Colors.black.withOpacity(0.4));
            });
    }).catchError((onError) {

    });
  }
  void _share(BuildContext context, String transactionName) async {
    var status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.storage.request();
    }

    if (status == PermissionStatus.granted) {
      imagePaths.clear();
      _imageFile = null;

      try {
        final captureImage = await screenshotController.capture(
          delay: Duration(milliseconds: 10),
          pixelRatio: 1.0,
        );
        if (captureImage != null) {
          _imageFile = captureImage;
        }

        final now = DateTime.now();
        final dateFormat = DateFormat('dd-MM-yyyy hh:mm');
        final dateTime = dateFormat.format(now);
        final screenShotName = transactionName + '_' + dateTime;

        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          showToast('Failed to access storage directory');
          return;
        }

        final filePath = '${directory.path}/$screenShotName.png';
        final imgFile = File(filePath);

        await imgFile.writeAsBytes(_imageFile!.buffer.asUint8List());
        imagePaths.add(imgFile.path);
        await Share.shareXFiles(
          [XFile(imgFile.path)],
          text: 'Share Receipt of Transaction from QPay',
        );
      } catch (e) {

        showToast('Failed to share receipt');
      }
    } else if (status == PermissionStatus.permanentlyDenied) {
      AppSettings.openAppSettings();
    } else {
      showToast('Storage permission is required to share receipt');
    }
  }


  */
/*void _share(BuildContext context,String transactionName) async {
    var status = await Permission.storage.status;
    if(status==PermissionStatus.granted) {
      imagePaths.clear();
      _imageFile = null;
      screenshotController.capture(
          delay: Duration(milliseconds: 10), pixelRatio: 1.0)
          .then((captureImage) async {
        if (captureImage != null) {
          _imageFile = captureImage;
        }
        var now = DateTime.now();
        var dateFormat = DateFormat('dd-MM-yyyy hh:mm');
        var dateTime = dateFormat.format(now);
        var screenShotName = transactionName + '_' + dateTime;
        final directory = (await getExternalStorageDirectory())!.path;
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
    if(status == PermissionStatus.denied){
      var requested =  await Permission.storage.request();
      if (requested==PermissionStatus.granted) {
        imagePaths.clear();
        _imageFile = null;
        screenshotController.capture(
            delay: Duration(milliseconds: 10), pixelRatio: 1.0)
            .then((captureImage) async {
          if (captureImage != null) {
            _imageFile = captureImage;
          }
          var now = DateTime.now();
          var dateFormat = DateFormat('dd-MM-yyyy hh:mm');
          var dateTime = dateFormat.format(now);
          var screenShotName = transactionName + '_' + dateTime;
          final directory = (await getExternalStorageDirectory())!.path;
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
      if(requested == PermissionStatus.permanentlyDenied){
        status = requested;
      }
    }
    if(status == PermissionStatus.permanentlyDenied){
      AppSettings.openAppSettings();
    }
  }*/ /*


  Widget _viewParams(String title, String value){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, softWrap: true ,style: TextStyle(color: Colours.text_gray,fontSize: Dimens.font_sp14,fontWeight: FontWeight.normal),),
        Text(value, softWrap: true ,style: TextStyle(color: Colours.text_gray,fontSize: Dimens.font_sp12,fontWeight: FontWeight.bold),),
      ],
    );
  }
}
*/
