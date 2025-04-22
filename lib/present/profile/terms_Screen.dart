import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:toyvalley/config/colors.dart';
import 'package:toyvalley/component/bar/simple_Bar.dart';

class TermsScreen extends StatefulWidget {
  TermsScreen({Key? key}) : super(key: key);

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final WebViewController _webViewController = WebViewController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Configure the WebView controller
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(MyColors.lightBlue)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://toyvalley.io/terms'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar(title: 'Terms of usage'),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (isLoading)
            Container(
              color: MyColors.lightBlue,
              child: const Center(
                child: CircularProgressIndicator(color: MyColors.orange),
              ),
            ),
        ],
      ),
    );
  }
}
