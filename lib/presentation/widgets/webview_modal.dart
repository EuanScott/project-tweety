import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'app_modal.dart';

/// Modal wrapper for presenting web content inside the app.
///
/// This widget is responsible only for hosting the web view and returning the
/// user's modal action. Any workflow-specific behaviour should remain in the
/// caller or in dedicated child widgets.
class const WebviewModal({super.key, required final String url})
    extends StatefulWidget {
  @override
  State<WebviewModal> createState() => _WebviewModalState();

  /// Shows a web view inside an app modal.
  ///
  /// [context] is used to resolve the [Navigator] and present the modal.
  /// [url] is the page loaded inside the web view.
  ///
  /// The returned [Future<bool?>] completes when the modal is dismissed and
  /// carries the value passed to `Navigator.pop`, where `true` represents
  /// confirm and `false` represents cancel.
  static Future<bool?> show(BuildContext context, String url) {
    return AppModal.blocking<bool>(
      context: context,
      child: WebviewModal(url: url),
    );
  }
}

class _WebviewModalState extends State<WebviewModal> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: InAppWebViewSettings(
              useWideViewPort: true,
              loadWithOverviewMode: true,
            ),
            onLoadStart: (controller, url) {
              setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) {
              setState(() => _isLoading = false);
            },
          ),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisSize: .min,
                children: [AppLoadingIndicator()],
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const .symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton.primary(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
