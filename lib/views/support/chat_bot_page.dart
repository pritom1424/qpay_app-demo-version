import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:printing/printing.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/providers/dashboard_provider.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/widgets/app_bar.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ChatBotWebView extends StatefulWidget {
  @override
  _ChatBotWebViewState createState() => _ChatBotWebViewState();
}

class _ChatBotWebViewState extends State<ChatBotWebView> {
  InAppWebViewController? webViewController;
  var dashboardProvider = DashboardProvider();

  double progress = 0;

  final FlutterTts flutterTts = FlutterTts();

  final ValueNotifier<bool> hideBackButton = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    flutterTts.setLanguage("bn-BD");

    flutterTts.setSpeechRate(0.5);

    flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    super.dispose();

    flutterTts.stop();

    webViewController?.dispose();
  }

  String cleanBanglaTextForPDF(String input) {
    String cleaned = input;
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'),
      (match) => match.group(1) ?? '',
    );
    cleaned = cleaned.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    List<String> tokens = cleaned.split(RegExp(r'(\n|।|:)'));
    List<String> resultLines = [];

    bool insidePoint =
        false; // Flag to know if we are inside a bullet/numbered point

    for (int i = 0; i < tokens.length; i++) {
      String token = tokens[i];
      if (token == null) continue;
      String t = token.trim();
      if (t.isEmpty) continue;
      if (t == ':' || t == '।') {
        if (resultLines.isNotEmpty) {
          String prev = resultLines.removeLast();
          if (!prev.endsWith(':') && !prev.endsWith('।')) {
            prev = prev + ' ' + t;
          } else {
            prev = prev + t;
          }
          resultLines.add(prev);
        } else {
          resultLines.add(t);
        }
        insidePoint = false; // a header separator should reset point state
        continue;
      }
      bool isBullet = t.startsWith('*') || t.startsWith('●');
      bool isNumbered = RegExp(r'^[0-9০-৯]+[.)]').hasMatch(t);
      bool endsWithColon = t.endsWith(':') || t.endsWith('।');

      if (isBullet || isNumbered) {
        resultLines.add(t);
        insidePoint = true;
      } else if (insidePoint) {
        resultLines.add(t);
        insidePoint =
            !endsWithColon; // If this line ends with colon, next line will be treated as a header start
      } else if (endsWithColon) {
        resultLines.add(t);
        insidePoint = false;
      } else {
        resultLines.add(t);
        insidePoint = false;
      }
    }
    String finalText = resultLines.join('\n');
    finalText = finalText.replaceAll(RegExp(r'^\*\s+', multiLine: true), '● ');

    return finalText.trim();
  }

  Future<void> _exportChatToPdfAndShare(String chatData) async {
    String? phoneNumber = dashboardProvider.user?.phoneNumber;
    if (phoneNumber != null) {
      final paragraphs = cleanBanglaTextForPDF(chatData).split('\n');
      DateTime now = DateTime.now();
      String formatted = intl.DateFormat('yyyy-MM-dd hh:mm a').format(now);

      final document = PdfDocument();
      final pageWidth = 595.0; // A4 width
      final pageHeight = 842.0; // A4 height
      const padding = 20.0;
      const fontSize = 18.0;

      final textStyle = TextStyle(
        fontFamily: 'TiroBangla',
        fontSize: fontSize,
        color: Colors.black,
      );

      int pIndex = 0;

      while (pIndex < paragraphs.length) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(
          recorder,
          Rect.fromLTWH(0, 0, pageWidth, pageHeight),
        );
        double yOffset = padding;

        while (pIndex < paragraphs.length) {
          String para = paragraphs[pIndex].trimRight();
          if (para.isEmpty) {
            yOffset += fontSize * 0.8;
            pIndex++;
            if (yOffset > pageHeight - padding) break;
            continue;
          }
          final maxWidth = pageWidth - 2 * padding;
          TextPainter tpAll = TextPainter(
            text: TextSpan(text: para, style: textStyle),
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: maxWidth);

          final availableHeight = pageHeight - padding - yOffset;
          if (tpAll.height <= availableHeight) {
            tpAll.paint(canvas, Offset(padding, yOffset));
            yOffset += tpAll.height + 6; // small paragraph spacing
            pIndex++;
            continue;
          }
          int low = 0;
          int high = para.length;
          int best = 0;

          while (low <= high) {
            int mid = (low + high) >> 1;
            String candidate = para.substring(0, mid).trimRight();
            if (candidate.isEmpty) {
              low = mid + 1;
              continue;
            }
            TextPainter tpCandidate = TextPainter(
              text: TextSpan(text: candidate, style: textStyle),
              textDirection: TextDirection.ltr,
            )..layout(maxWidth: maxWidth);

            if (tpCandidate.height <= availableHeight) {
              best = mid;
              low = mid + 1;
            } else {
              high = mid - 1;
            }
          }
          if (best == 0) {
            if (yOffset == padding) {
              int low2 = 1;
              int high2 = para.length;
              int best2 = 0;
              while (low2 <= high2) {
                int mid = (low2 + high2) >> 1;
                final cand = para.substring(0, mid);
                TextPainter tp = TextPainter(
                  text: TextSpan(text: cand, style: textStyle),
                  textDirection: TextDirection.ltr,
                )..layout(maxWidth: maxWidth);
                if (tp.height <= availableHeight) {
                  best2 = mid;
                  low2 = mid + 1;
                } else {
                  high2 = mid - 1;
                }
              }
              if (best2 == 0) break;

              int cut = best2;
              String piece = para.substring(0, cut).trimRight();
              TextPainter tpPiece = TextPainter(
                text: TextSpan(text: piece, style: textStyle),
                textDirection: TextDirection.ltr,
              )..layout(maxWidth: maxWidth);

              tpPiece.paint(canvas, Offset(padding, yOffset));
              yOffset += tpPiece.height + 6;
              paragraphs[pIndex] = para.substring(cut).trimLeft();
              continue;
            } else {
              break;
            }
          }
          int cut = best;
          final lastSpace = para.lastIndexOf(RegExp(r'\s'), cut);
          if (lastSpace > 0) cut = lastSpace;
          String piece = para.substring(0, cut).trimRight();
          if (piece.isEmpty) {
            piece = para.substring(0, best).trimRight();
            cut = best;
          }
          TextPainter tpPiece = TextPainter(
            text: TextSpan(text: piece, style: textStyle),
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: maxWidth);
          if (tpPiece.height > availableHeight) {
            break;
          }

          tpPiece.paint(canvas, Offset(padding, yOffset));
          yOffset += tpPiece.height + 6;
          paragraphs[pIndex] = para.substring(cut).trimLeft();
        } // end inner while - page filled or paragraphs exhausted
        final picture = recorder.endRecording();
        final image = await picture.toImage(
          pageWidth.toInt() + 80,
          pageHeight.toInt() + 80,
        );
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        final page = document.pages.add();
        page.graphics.drawImage(
          PdfBitmap(byteData!.buffer.asUint8List()),
          Rect.fromLTWH(0, 0, pageWidth - 1, pageHeight - 1),
        );
      } // end outer while - all paragraphs processed

      final bytes = await document.saveAsBytes();
      document.dispose();

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: MyAppBar(centerTitle: "Chat History Preview"),

            body: PdfPreview(
              build: (format) async => bytes,
              pdfFileName: 'chat_history.pdf',
              allowSharing: true,
              allowPrinting: false,
              shareActionExtraSubject: "$formatted-Chat History-$phoneNumber",
            ),
          ),
        ),
      );
    } else {
      setState(() {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Unauthorized access")));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.supportchatBot),
        titleTextStyle: TextStyles.textBold14.copyWith(color: Colors.black),
        centerTitle: true,
        leading: ValueListenableBuilder<bool>(
          valueListenable: hideBackButton,
          builder: (context, value, _) {
            return !value
                ? IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : SizedBox();
          },
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: hideBackButton,
            builder: (context, value, _) {
              if (value) {
                return PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: (String result) async {
                    if (result == 'end') {
                      hideBackButton.value = false;

                      await webViewController?.evaluateJavascript(
                        source: '''
    if (window.endConversationFromFlutter) {
      window.endConversationFromFlutter();
    } else if (typeof endConversation === 'function') {
      (async function(){
        try { await endConversation(); } catch(e) { console.error(e); }
        try {
          if (typeof handleSessionEnded === 'function') handleSessionEnded();
          var ss = document.getElementById('startScreen');
          var cs = document.getElementById('chatScreen');
          if (ss) ss.classList.remove('hidden');
          if (cs) cs.classList.add('hidden');
        } finally {
          setTimeout(function(){ location.reload(); }, 1000);
        }
      })();
    } else {
      console.warn("endConversation not defined yet");
    }
  ''',
                      );
                      await Future.delayed(const Duration(milliseconds: 1200));
                      await CookieManager.instance().deleteAllCookies();
                    } else if (result == 'export') {
                      await webViewController?.evaluateJavascript(
                        source: 'exportChat();',
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'export',
                          child: Text('Export Chat'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'end',
                          child: Text('End Conversation'),
                        ),
                      ],
                );
              }

              return SizedBox(); // Hide the button when on the start screen
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri("https://chatbot.qpaybd.com.bd/index.html"),
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;

              controller.addJavaScriptHandler(
                handlerName: "ExportChatHandler",
                callback: (args) async {
                  final chatData = args.isNotEmpty ? args[0] : "";

                  if (chatData is String && chatData.isNotEmpty) {
                    await _exportChatToPdfAndShare(chatData);
                  }
                },
              );

              controller.addJavaScriptHandler(
                handlerName: "StartButtonClicked",
                callback: (args) async {
                  hideBackButton.value = true;

                  return null;
                },
              );

              controller.addJavaScriptHandler(
                handlerName: "TTSHandler",
                callback: (args) async {
                  final text = args.isNotEmpty ? args[0] : "";

                  if (text is String && text.trim().isNotEmpty) {
                    await flutterTts.stop();
                  }

                  return null;
                },
              );

              controller.addJavaScriptHandler(
                handlerName: 'EndButtonClicked',
                callback: (args) {
                  flutterTts.stop();

                  hideBackButton.value = false;
                },
              );
            },
            onLoadStop: (controller, url) async {
              await Future.delayed(Duration(milliseconds: 500));

              await controller.evaluateJavascript(
                source: '''

function exportChat() {

const messages = [];

const messageElements = document.querySelectorAll('.user-message, .bot-message');


messageElements.forEach(el => {

const sender = el.classList.contains('user-message') ? 'You' : 'Bot';

const text = el.textContent.trim();

messages.push(sender + " - " + text);

});


const chatData = messages.join('\\n\\n'); // Join messages with newlines

window.flutter_inappwebview.callHandler('ExportChatHandler', chatData);

}

const startBtn = document.getElementById('startButton');

if (startBtn && !startBtn._flutterHooked) {

startBtn._flutterHooked = true;

startBtn.addEventListener('click', () => {

window.flutter_inappwebview.callHandler('StartButtonClicked');

});

}

const endBtn = document.getElementById('endButton');

if (endBtn && !endBtn._reloadHooked) {

endBtn._reloadHooked = true;

endBtn.addEventListener('click', () => {

setTimeout(() => {

window.flutter_inappwebview.callHandler('EndButtonClicked');

location.reload();

}, 1000);

});

}

const input = document.getElementById("messageInput");

const sendBtn = document.getElementById("sendButton");

if (input && sendBtn) {

input.addEventListener("keydown", function(event) {

if (event.key === "Enter") {

event.preventDefault();

sendBtn.click();

input.blur();

}

});

}

if (typeof chatMessagesObserverInitialized === 'undefined') {

const chatMessagesDiv = document.getElementById("chatMessages");

const observer = new MutationObserver(() => {

const messages = chatMessagesDiv.querySelectorAll('.bot-message');

if (messages.length > 0) {

const last = messages[messages.length - 1];

if (!last.dataset.spoken) {

last.dataset.spoken = 'true';

const text = last.textContent;

window.flutter_inappwebview.callHandler('TTSHandler', text);

}

}

});

if (chatMessagesDiv) {

observer.observe(chatMessagesDiv, { childList: true, subtree: true });

window.chatMessagesObserverInitialized = true;

}

}

''',
              );
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              if (challenge.protectionSpace.host == "chatbot.qpaybd.com.bd") {
                return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED,
                );
              }

              return ServerTrustAuthResponse(
                action: ServerTrustAuthResponseAction.CANCEL,
              );
            },
            onProgressChanged: (controller, progressValue) {
              setState(() {
                progress = progressValue / 100;
              });
            },
          ),
          progress < 1.0
              ? LinearProgressIndicator(value: progress)
              : SizedBox(),
        ],
      ),
    );
  }
}
