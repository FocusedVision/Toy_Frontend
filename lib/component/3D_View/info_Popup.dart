import 'package:flutter/material.dart';
import 'package:toyvalley/config/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InfoPopup extends StatefulWidget {
  const InfoPopup({super.key, required this.onClose, required this.url});

  final VoidCallback onClose;
  final String? url;

  @override
  State<InfoPopup> createState() => _InfoPopupState();
}

class _InfoPopupState extends State<InfoPopup> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(
            MyColors.infoTabBg,
          ) // Setting the background color
          ..loadRequest(
            Uri.parse(widget.url ?? 'https://toyvalley.io'),
          ); // Load URL
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            widget.onClose();
          },
          child: IgnorePointer(child: Container()),
        ),
        Positioned.fill(
          child: Container(
            key: const Key("info_tab"),
            padding: EdgeInsets.only(
              left: 35,
              right: 35,
              top: 60,
              bottom: screenSize.height * 0.075 + 6,
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(2, 3),
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: WebViewWidget(controller: _controller), // Updated widget
              ),
            ),
          ),
        ),
      ],
    );
  }
}
