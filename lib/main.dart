import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AGUI Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> with WidgetsBindingObserver {
  InAppWebViewController? webViewController;
  double progress = 0;
  final String url = "https://srv1286876.hstgr.cloud/chatbot/login";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-load if necessary or ensure it's still running
      // Following the Ionic logic: this.reopenBrowser();
      webViewController?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            progress < 1.0
                ? LinearProgressIndicator(value: progress, color: Colors.blueAccent)
                : Container(),
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(url)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  transparentBackground: false,
                  supportZoom: false,
                  allowsInlineMediaPlayback: true,
                  useHybridComposition: true,
                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    this.progress = progress / 100;
                  });
                },
                onLoadStop: (controller, url) {
                  setState(() {
                    this.progress = 1.0;
                  });
                },
                onReceivedError: (controller, request, error) {
                  print("WebView Error: ${error.description}");
                },
                onReceivedHttpError: (controller, request, errorResponse) {
                  print("WebView HTTP Error: ${errorResponse.statusCode}");
                },
                onReceivedServerTrustAuthRequest: (controller, challenge) async {
                  print("WebView SSL Error: ${challenge.protectionSpace.host}");
                  return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
