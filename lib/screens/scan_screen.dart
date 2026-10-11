import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/data/providers.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../services/ocr_service.dart';
import '../services/validators.dart';

/// Returned to the Lookup screen: which provider the number belongs to
/// and the digits themselves.
class ScanResult {
  const ScanResult({required this.providerId, required this.number});

  final String providerId;
  final String number;
}

/// Full-screen bill scanner. OCR runs fully on-device (ML Kit Latin model).
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key, this.lockProviderId});

  /// When opened from a specific provider's Lookup, prefer that provider
  /// when the scanned length fits its rule.
  final String? lockProviderId;

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final OcrService _ocr = OcrService();
  CameraController? _camera;
  bool _ready = false;
  bool _sheetOpen = false;
  bool _torch = false;
  bool _processingGallery = false;
  String? _initError;
  PermissionStatus _perm = PermissionStatus.denied;
  int _frames = 0;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    unawaited(_disposeCamera());
    _ocr.dispose();
    super.dispose();
  }

  Future<void> _disposeCamera() async {
    final controller = _camera;
    _camera = null;
    if (controller == null) return;
    try {
      await controller.stopImageStream();
    } catch (_) {
      // Stream may already be stopped.
    }
    await controller.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.status;
    if (!mounted) return;
    setState(() => _perm = status);
    if (status.isGranted) await _initCamera();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() => _perm = status);
    if (status.isGranted) await _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _initError = 'NO_CAMERA');
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = controller;
        _ready = true;
      });
      await controller.startImageStream(_onFrame);
    } catch (e) {
      if (mounted) setState(() => _initError = e.toString());
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_sheetOpen || !mounted || _camera == null) return;
    _frames++;
    if (_frames % 15 != 0) return; // ~2 fps is plenty for a printed number.
    final text = await _ocr.processCameraImage(
      image,
      _camera!.description,
      _camera!.value.deviceOrientation,
    );
    if (text == null || text.trim().isEmpty) return;
    if (_sheetOpen || !mounted) return;
    final candidates = extractCandidates(text);
    if (candidates.isEmpty || _sheetOpen || !mounted) return;
    _openSheet(candidates);
  }

  void _openSheet(List<OcrCandidate> candidates) {
    if (_sheetOpen || !mounted) return;
    _sheetOpen = true;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ScanResultSheet(
        candidate: candidates.first,
        candidates: candidates,
        lockProviderId: widget.lockProviderId,
        onUse: (providerId, number) {
          Navigator.of(context).pop(); // sheet
          Navigator.of(context)
              .pop(ScanResult(providerId: providerId, number: number));
        },
      ),
    ).then((_) {
      _sheetOpen = false;
    });
  }

  Future<void> _pickFromGallery() async {
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final file =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _processingGallery = true);
    try {
      final text = await _ocr.processImageFile(File(file.path));
      final candidates = extractCandidates(text);
      if (!mounted) return;
      if (candidates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.noNumberFound)),
        );
      } else {
        _openSheet(candidates);
      }
    } finally {
      if (mounted) setState(() => _processingGallery = false);
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _camera;
    if (controller == null || !_ready) return;
    final next = !_torch;
    try {
      await controller.setFlashMode(
          next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _torch = next);
    } catch (_) {
      // Torch unavailable on this device — stay silent.
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final theme = Theme.of(context);
    final colors = AppColors.of(theme.brightness);

    if (!_perm.isGranted) {
      return _PermissionScreen(
        permanentlyDenied: _perm.isPermanentlyDenied,
        onAllow: _requestPermission,
        onOpenSettings: openAppSettings,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_ready && _camera != null)
            Positioned.fill(child: CameraPreview(_camera!))
          else
            Positioned.fill(
              child: Center(
                child: _initError == null
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          strings.tryAgain,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
          // Dimmed overlay with the viewfinder + green corner brackets.
          Positioned.fill(
            child: CustomPaint(
              painter: _ViewfinderPainter(brand: colors.brand),
            ),
          ),
          // Top bar.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.close,
                    label: strings.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  _RoundIconButton(
                    icon: _torch ? Icons.flash_on : Icons.flash_off,
                    label: _torch ? strings.torchOff : strings.torchOn,
                    onPressed: _toggleTorch,
                  ),
                ],
              ),
            ),
          ),
          // Bottom bar: hint + gallery.
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      strings.scanHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                        shadows: [
                          Shadow(
                              color: Colors.black54,
                              blurRadius: 8,
                              offset: Offset(0, 1))
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _RoundIconButton(
                      icon: Icons.photo_library,
                      label: strings.gallery,
                      onPressed: _pickFromGallery,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_processingGallery)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 12),
                      Text(strings.processing,
                          style:
                              const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.black54,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class _PermissionScreen extends StatelessWidget {
  const _PermissionScreen({
    required this.permanentlyDenied,
    required this.onAllow,
    required this.onOpenSettings,
  });

  final bool permanentlyDenied;
  final VoidCallback onAllow;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final theme = Theme.of(context);
    final colors = AppColors.of(theme.brightness);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: strings.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.brandSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.videocam_off,
                    size: 36, color: colors.brand),
              ),
              const SizedBox(height: 20),
              Text(strings.cameraPermissionTitle,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(strings.cameraPermissionBody,
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: colors.muted),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed:
                    permanentlyDenied ? onOpenSettings : onAllow,
                child: Text(permanentlyDenied
                    ? strings.openSettings
                    : strings.allowCamera),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet shown when OCR is confident: the number in large Sora,
/// company chips when the company can't be inferred, "Use this number".
class _ScanResultSheet extends StatefulWidget {
  const _ScanResultSheet({
    required this.candidate,
    required this.candidates,
    required this.lockProviderId,
    required this.onUse,
  });

  final OcrCandidate candidate;
  final List<OcrCandidate> candidates;
  final String? lockProviderId;
  final void Function(String providerId, String number) onUse;

  @override
  State<_ScanResultSheet> createState() => _ScanResultSheetState();
}

class _ScanResultSheetState extends State<_ScanResultSheet> {
  late OcrCandidate _selected;
  String? _providerId;

  @override
  void initState() {
    super.initState();
    _selected = widget.candidate;
    _providerId = _inferProvider(widget.candidate);
  }

  /// Returns a provider id when it can be inferred, else null.
  String? _inferProvider(OcrCandidate c) {
    // Locked lookup: use it when the length fits its rule.
    final lock = widget.lockProviderId == null
        ? null
        : providerById(widget.lockProviderId!);
    if (lock != null &&
        c.digits.length >= lock.minLength &&
        c.digits.length <= lock.maxLength) {
      return lock.id;
    }
    if (c.kind == OcrKind.kelectric13) return 'kelectric';
    return null; // pitc14 / gas need the user to confirm the company.
  }

  List<BillProvider> _companyOptions() {
    if (_selected.kind == OcrKind.gas) {
      return [providerById('sngpl')!, providerById('ssgc')!];
    }
    // 14-digit PITC reference: any of the 10 DISCOs.
    return kProviders
        .where((p) =>
            p.kind == UtilityKind.electricity && p.id != 'kelectric')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final strings = Strings(Localizations.localeOf(context).languageCode);
    final theme = Theme.of(context);
    final provider =
        _providerId == null ? null : providerById(_providerId!);
    final needsCompany = _providerId == null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            provider == null
                ? strings.scanTitle
                : strings.foundReference(provider.code),
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Candidate picker when several numbers were found.
          if (widget.candidates.length > 1)
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.candidates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final c = widget.candidates[i];
                  final selected = c.digits == _selected.digits;
                  return ChoiceChip(
                    label: Text(groupDigits(c.digits),
                        style: tabular(theme.textTheme.titleSmall!
                            .copyWith(fontFamily: 'Sora'))),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      _selected = c;
                      _providerId = _inferProvider(c);
                    }),
                  );
                },
              ),
            ),
          if (widget.candidates.length > 1) const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.of(theme.brightness).brandSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              groupDigits(_selected.digits),
              textAlign: TextAlign.center,
              style: tabular(theme.textTheme.displayLarge!.copyWith(
                fontFamily: 'Sora',
                fontSize: 26,
              )),
            ),
          ),
          if (needsCompany) ...[
            const SizedBox(height: 16),
            Text(strings.confirmCompany,
                style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in _companyOptions())
                  ChoiceChip(
                    label: Text(p.code),
                    selected: _providerId == p.id,
                    onSelected: (_) =>
                        setState(() => _providerId = p.id),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _providerId == null
                ? null
                : () => widget.onUse(_providerId!, _selected.digits),
            child: Text(strings.useNumber),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.tryAgain),
          ),
        ],
      ),
    );
  }
}

/// Dimmed overlay with a rounded viewfinder cut-out and green corner brackets.
class _ViewfinderPainter extends CustomPainter {
  _ViewfinderPainter({required this.brand});

  final Color brand;

  @override
  void paint(Canvas canvas, Size size) {
    final w = (size.width * 0.84).clamp(0.0, size.width - 32);
    const h = 190.0;
    final rect = RRect.fromLTRBR(
      (size.width - w) / 2,
      (size.height - h) / 2,
      (size.width + w) / 2,
      (size.height + h) / 2,
      const Radius.circular(20),
    );

    final dim = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(rect);
    dim.fillType = PathFillType.evenOdd;
    canvas.drawPath(dim, Paint()..color = Colors.black.withValues(alpha: 0.55));

    // Green corner brackets.
    final r = rect.outerRect;
    const b = 30.0;
    const inset = 4.0;
    final p = Paint()
      ..color = brand
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    void bracket(double x, double y, double dx, double dy) {
      canvas.drawLine(Offset(x, y), Offset(x + dx, y), p);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy), p);
    }

    bracket(r.left + inset, r.top + inset, b, b);
    bracket(r.right - inset, r.top + inset, -b, b);
    bracket(r.left + inset, r.bottom - inset, b, -b);
    bracket(r.right - inset, r.bottom - inset, -b, -b);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter old) =>
      old.brand != brand;
}
