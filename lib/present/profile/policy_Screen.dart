import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:toyvalley/config/colors.dart';
import 'package:toyvalley/component/bar/simple_Bar.dart';

class PolicyScreen extends StatefulWidget {
  const PolicyScreen({Key? key}) : super(key: key);

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  late final WebViewController _webViewController;
  bool isLoading =
      true; // To show the loading indicator while the page is loading

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) {
                // Hide the loading indicator when the page is finished loading
                setState(() {
                  isLoading = false;
                });
              },
            ),
          )
          ..loadRequest(Uri.parse('https://toyvalley.io/privacy'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppBar(title: 'Privacy Policy'),
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
