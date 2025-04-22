import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;

import 'package:webview_flutter/webview_flutter.dart';
import 'package:android_intent_plus/android_intent.dart' as android_content;
import 'package:url_launcher/url_launcher.dart';

import 'html_builder.dart'; // Assuming this is your custom HTML builder
import 'model_View.dart'; // Assuming this is your custom widget

class ModelViewerState extends State<ModelViewer> {
  late final WebViewController _controller;
  HttpServer? _proxy;
  late String _proxyURL;

  Timer? timer;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();

    // Initialize WebView controller
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(onNavigationRequest: _handleNavigationRequest),
          );

    _initProxy();

    // Timer to check model loading status
    timer = Timer(const Duration(seconds: 4), isModelLoaded);
  }

  @override
  void dispose() {
    timer?.cancel();
    _proxy?.close(force: true);
    super.dispose();
  }

  // Helper method to handle navigation requests in WebView
  FutureOr<NavigationDecision> _handleNavigationRequest(
    NavigationRequest navigation,
  ) async {
    debugPrint('ModelViewer wants to load: <${navigation.url}>');

    if (Platform.isIOS && navigation.url == widget.iosSrc) {
      await launchUrl(
        Uri.parse(navigation.url),
        mode: LaunchMode.platformDefault,
      );
      return NavigationDecision.prevent;
    }

    if (Platform.isAndroid && navigation.url.startsWith("intent://")) {
      try {
        final fileURL = _getFileUrl();
        final intent = android_content.AndroidIntent(
          action: "android.intent.action.VIEW",
          data:
              Uri(
                scheme: 'https',
                host: 'arvr.google.com',
                path: '/scene-viewer/1.0',
                queryParameters: {'mode': 'ar_preferred', 'file': fileURL},
              ).toString(),
          package: "com.google.android.googlequicksearchbox",
          arguments: {
            'browser_fallback_url':
                'market://details?id=com.google.android.googlequicksearchbox',
          },
        );
        await intent.launch();
      } catch (error) {
        debugPrint('ModelViewer Intent Error: $error');
      }
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  // Build Method
  @override
  Widget build(BuildContext context) {
    if (_proxy == null) {
      return const Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Loading Model Viewer...',
        ),
      );
    }

    return Opacity(
      opacity: isLoaded ? 1 : 0.01,
      child: WebViewWidget(
        controller:
            _controller
              ..loadRequest(Uri.parse(_proxyURL))
              ..addJavaScriptChannel(
                'messageHandler',
                onMessageReceived: _handleJavaScriptChannel,
              )
              ..addJavaScriptChannel(
                'Print',
                onMessageReceived: (message) => debugPrint(message.message),
              ),
      ),
    );
  }

  // JavaScript Channel Handler
  void _handleJavaScriptChannel(JavaScriptMessage message) {
    if (message.message == "1" || message.message == "true") {
      widget.callBack?.call();
      setState(() {
        isLoaded = true;
      });
    } else if (message.message == "2") {
      widget.onAnimationFinished?.call();
    } else {
      setTimer();
    }
  }

  // Set a timer to check model loading
  void setTimer() {
    timer = Timer(const Duration(seconds: 1), isModelLoaded);
  }

  // Check if model is loaded
  void isModelLoaded() {
    _controller.runJavaScriptReturningResult('isLoaded()').then((result) {
      debugPrint('Model loaded status: $result');
    });
  }

  void play() {
    _controller.runJavaScriptReturningResult('play()').then((result) {
      debugPrint('Model play status: $result');
    });
  }

  void reset() {
    _controller.runJavaScriptReturningResult('reset()').then((result) {
      debugPrint('Model reset status: $result');
    });
  }

  void pause() {
    _controller.runJavaScriptReturningResult('pause()').then((result) {
      debugPrint('Model pause status: $result');
    });
  }

  void zoom(String val) {
    _controller.runJavaScriptReturningResult('zoom($val)').then((result) {
      debugPrint('Model zoom($val) status: $result');
    });
  }

  // Initialize Proxy Server
  Future<void> _initProxy() async {
    final url = Uri.parse(widget.src);
    _proxy = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

    setState(() {
      final host = _proxy!.address.address;
      final port = _proxy!.port;
      _proxyURL = "http://$host:$port/";
    });

    _proxy!.listen((request) async {
      final response = request.response;

      try {
        switch (request.uri.path) {
          case '/':
          case '/index.html':
            final htmlTemplate = await rootBundle.loadString(
              'assets/template.html',
            );
            final html = utf8.encode(_buildHTML(htmlTemplate));
            response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.html
              ..add(html);
            break;

          case '/model-viewer.min.js':
            final jsCode = await _readAsset('assets/model-viewer.min.js');
            response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType(
                'application',
                'javascript',
                charset: 'utf-8',
              )
              ..add(jsCode);
            break;

          case '/model':
            final data =
                await (url.isScheme("file")
                    ? _readFile(url.path)
                    : _readAsset(url.path));
            response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.binary
              ..add(data);
            break;

          default:
            response
              ..statusCode = HttpStatus.notFound
              ..write("Resource '${request.uri}' not found");
        }
      } catch (e) {
        response
          ..statusCode = HttpStatus.internalServerError
          ..write("Error serving request: $e");
      } finally {
        await response.close();
      }
    });
  }

  // Build HTML from template
  String _buildHTML(String htmlTemplate) {
    return HTMLBuilder.build(
      htmlTemplate: htmlTemplate,
      src: '/model',
      alt: widget.alt,
      poster: widget.poster,
      seamlessPoster: widget.seamlessPoster,
      loading: widget.loading,
      reveal: widget.reveal,
      withCredentials: widget.withCredentials,
      ar: widget.ar,
      arModes: widget.arModes,
      arScale: widget.arScale,
      arPlacement: widget.arPlacement,
      iosSrc: widget.iosSrc,
      xrEnvironment: widget.xrEnvironment,
      cameraControls: widget.cameraControls,
      enablePan: widget.enablePan,
      disableZoom: widget.disableZoom,
      autoRotate: widget.autoRotate,
      backgroundColor: widget.backgroundColor,
      relatedCss: widget.relatedCss,
      relatedJs: widget.relatedJs,
    );
  }

  Future<Uint8List> _readAsset(String key) async {
    final data = await rootBundle.load(key);
    return data.buffer.asUint8List();
  }

  Future<Uint8List> _readFile(String path) async {
    return File(path).readAsBytes();
  }

  String _getFileUrl() {
    final url = Uri.parse(widget.src);
    return (url.isAbsolute && !url.isScheme("file"))
        ? url.toString()
        : p.joinAll([_proxyURL, 'model']);
  }
}
