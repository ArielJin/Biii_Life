import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebScreen extends StatefulWidget {

  final String title;
  final String selectedUrl;

  const AppWebScreen({super.key, required this.title, required this.selectedUrl});

  @override
  State<StatefulWidget> createState() => _AppWebScreenState();

}

class _AppWebScreenState extends State<AppWebScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title??'', style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: () {
            finish(context);
          },
        ),
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // Update loading bar.
              },
              onPageStarted: (String url) {},
              onPageFinished: (String url) {},
              onWebResourceError: (WebResourceError error) {},
              // onNavigationRequest: (NavigationRequest request) {
              //   if (request.url.startsWith('https://www.youtube.com/')) {
              //     return NavigationDecision.prevent;
              //   }
              //   return NavigationDecision.navigate;
              // },
            ),
          )
          ..loadRequest(Uri.parse(widget.selectedUrl)),
       ),
    );
  }

}