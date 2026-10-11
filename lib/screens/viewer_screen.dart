import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/data/providers.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../services/domain_guard.dart';
import '../services/pdf_service.dart';
import '../services/validators.dart';
import '../state/app_state.dart';
import '../widgets/official_badge.dart';
import '../widgets/save_bill_sheet.dart';

/// Opens the provider's official bill page inside the app.
/// Only the provider's allowed domains may load; everything else is
/// blocked with a snackbar. No scraping, no accounts, no analytics.
class ViewerScreen extends ConsumerStatefulWidget {
  const ViewerScreen({
    super.key,
    required this.provider,
    required this.reference,
  });

  final BillProvider provider;
  final String reference;

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _loadError = false;
  bool _savingPdf = false;
  String _liveDomain = '';

  @override
  void initState() {
    super.initState();
    _liveDomain = Uri.parse(widget.provider.url).host;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (mounted) setState(() => _progress = p);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _loadError = false);
          },
          onUrlChange: (change) {
            final url = change.url;
            if (url == null) return;
            final host = Uri.tryParse(url)?.host ?? '';
            if (host.isNotEmpty && mounted) {
              setState(() => _liveDomain = host);
            }
          },
          onWebResourceError: (error) {
            // Main-frame failures (e.g. no connection) -> friendly retry UI.
            if (error.isForMainFrame == true && mounted) {
              setState(() => _loadError = true);
            }
          },
          onNavigationRequest: (request) {
            final ok = isAllowedUrl(request.url, widget.provider.allowedDomains);
            if (!ok && mounted) {
              final strings = Strings(
                  Localizations.localeOf(context).languageCode);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.blockedLink)),
              );
            }
            return ok
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.provider.url));
  }

  Future<void> _copyNumber() async {
    await Clipboard.setData(ClipboardData(text: widget.reference));
    if (!mounted) return;
    final strings =
        Strings(Localizations.localeOf(context).languageCode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.copied)),
    );
  }

  Future<void> _savePdf() async {
    if (_savingPdf) return;
    setState(() => _savingPdf = true);
    final strings =
        Strings(Localizations.localeOf(context).languageCode);
    try {
      final current = await _controller.currentUrl() ?? widget.provider.url;
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final path = await PdfService.printUrlToPdf(
        url: current,
        fileName: 'bill_${widget.provider.id}_$stamp',
      );
      await ref.read(vaultProvider.notifier).addFile(
            providerId: widget.provider.id,
            title: '${widget.provider.code} ${strings.saveBill}',
            sourcePath: path,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.pdfSaved)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.pdfFailed)),
      );
    } finally {
      if (mounted) setState(() => _savingPdf = false);
    }
  }

  Future<void> _share() async {
    final current = await _controller.currentUrl() ?? widget.provider.url;
    await Share.shareUri(Uri.parse(current));
  }

  Future<void> _saveBill() async {
    final strings =
        Strings(Localizations.localeOf(context).languageCode);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SaveBillSheet(
        provider: widget.provider,
        reference: widget.reference,
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.billSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final theme = Theme.of(context);
    final colors = AppColors.of(theme.brightness);

    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          button: true,
          label: strings.close,
          child: IconButton(
            icon: const Icon(Icons.close),
            tooltip: strings.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(widget.provider.code),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: Center(
              child: OfficialBadge(domain: _liveDomain, compact: true),
            ),
          ),
          Semantics(
            button: true,
            label: strings.reload,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: strings.reload,
              onPressed: () {
                setState(() => _loadError = false);
                _controller.reload();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_progress < 100 && !_loadError)
            LinearProgressIndicator(value: _progress / 100),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loadError) _OfflineOverlay(onRetry: () {
                  setState(() => _loadError = false);
                  _controller.reload();
                }),
              ],
            ),
          ),
          // Pinned strip: the number stays visible so it can be copied
          // into the official form.
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.line)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    groupDigits(widget.reference),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tabular(theme.textTheme.titleMedium!
                        .copyWith(fontFamily: 'Sora')),
                  ),
                ),
                TextButton.icon(
                  onPressed: _copyNumber,
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(strings.copy),
                ),
              ],
            ),
          ),
          // Action bar.
          Container(
            color: colors.surface,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _savingPdf ? null : _savePdf,
                    icon: _savingPdf
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.picture_as_pdf, size: 20),
                    label: Text(strings.savePdf),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _share,
                    icon: const Icon(Icons.share, size: 20),
                    label: Text(strings.share),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _saveBill,
                    icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                    label: Text(strings.saveBill),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineOverlay extends StatelessWidget {
  const _OfflineOverlay({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final theme = Theme.of(context);
    final colors = AppColors.of(theme.brightness);
    return Container(
      color: colors.background,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 48, color: colors.muted),
            const SizedBox(height: 16),
            Text(strings.offlineTitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(strings.offlineBody,
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: colors.muted),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              child: Text(strings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
