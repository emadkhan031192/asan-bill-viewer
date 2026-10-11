import 'package:flutter/material.dart';

import '../data/providers.dart';
import '../../models/bill_status.dart';

/// Brand + surface palettes, exactly as specified in the design brief.
class AppColors {
  const AppColors({
    required this.background,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.line,
    required this.brand,
    required this.brandSoft,
    required this.brandInkOn,
  });

  final Color background;
  final Color surface;
  final Color ink;
  final Color muted;
  final Color line;
  final Color brand;
  final Color brandSoft;

  /// Text/icon colour drawn on top of [brand].
  final Color brandInkOn;

  static const light = AppColors(
    background: Color(0xFFF2F6F3),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF10241F),
    muted: Color(0xFF4F655F),
    line: Color(0xFFDCE5E0),
    brand: Color(0xFF0E7A4F),
    brandSoft: Color(0xFFDDF1E7),
    brandInkOn: Color(0xFFFFFFFF),
  );

  static const dark = AppColors(
    background: Color(0xFF0A1411),
    surface: Color(0xFF12211C),
    ink: Color(0xFFE8F2EE),
    muted: Color(0xFF8CA69E),
    line: Color(0xFF203630),
    brand: Color(0xFF3DD68C),
    brandSoft: Color(0xFF143326),
    brandInkOn: Color(0xFF06231A),
  );

  static AppColors of(Brightness brightness) =>
      brightness == Brightness.light ? light : dark;
}

/// Base utility colours (used for the slip's top band and icon boxes).
Color utilityBand(UtilityKind kind) {
  switch (kind) {
    case UtilityKind.electricity:
      return const Color(0xFFF2A900);
    case UtilityKind.gas:
      return const Color(0xFF3B7BFF);
    case UtilityKind.telecom:
      return const Color(0xFF8A5CFF);
    case UtilityKind.water:
      return const Color(0xFF12A9B8);
  }
}

/// Tinted chip/icon-box pair for a utility kind.
/// Pairs are hand-picked to keep text ≥ 4.5:1 against the tint in each theme.
({Color bg, Color fg}) utilityTint(UtilityKind kind, Brightness brightness) {
  final light = brightness == Brightness.light;
  switch (kind) {
    case UtilityKind.electricity:
      return light
          ? (bg: const Color(0xFFFBF0D3), fg: const Color(0xFF7A5200))
          : (bg: const Color(0xFF3A2C08), fg: const Color(0xFFFFC53D));
    case UtilityKind.gas:
      return light
          ? (bg: const Color(0xFFE3ECFF), fg: const Color(0xFF1F4FCC))
          : (bg: const Color(0xFF1B2C5E), fg: const Color(0xFF9DB9FF));
    case UtilityKind.telecom:
      return light
          ? (bg: const Color(0xFFECE4FF), fg: const Color(0xFF5B2FD6))
          : (bg: const Color(0xFF2E1F5E), fg: const Color(0xFFC4A8FF));
    case UtilityKind.water:
      return light
          ? (bg: const Color(0xFFDFF5F8), fg: const Color(0xFF0B6E78))
          : (bg: const Color(0xFF0C3A40), fg: const Color(0xFF7FE3EE));
  }
}

/// Status chip pair: green = paid, amber = ≤3 days left, red = due today /
/// overdue, muted = anything else. Pairs keep text ≥ 4.5:1 in each theme.
({Color bg, Color fg}) statusTint(DueStatus status, Brightness brightness) {
  final light = brightness == Brightness.light;
  switch (status) {
    case DueStatus.paid:
      return light
          ? (bg: const Color(0xFFDDF1E7), fg: const Color(0xFF0B5C3B))
          : (bg: const Color(0xFF143326), fg: const Color(0xFF6FE3A5));
    case DueStatus.dueSoon:
      return light
          ? (bg: const Color(0xFFFBF0D3), fg: const Color(0xFF7A5200))
          : (bg: const Color(0xFF3A2C08), fg: const Color(0xFFFFC53D));
    case DueStatus.dueToday:
    case DueStatus.overdue:
      return light
          ? (bg: const Color(0xFFFDE7E7), fg: const Color(0xFFB3261E))
          : (bg: const Color(0xFF4A1D1D), fg: const Color(0xFFFF9B8A));
    case DueStatus.upcoming:
    case DueStatus.noDueDate:
      return light
          ? (bg: const Color(0xFFE9EFEc), fg: const Color(0xFF4F655F))
          : (bg: const Color(0xFF1B2E28), fg: const Color(0xFF8CA69E));
  }
}

/// Sora carries tabular figures for headings, numbers and domains.
TextStyle tabular(TextStyle style) => style.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

TextTheme _buildTextTheme({
  required String displayFont,
  required String bodyFont,
  required bool isUrdu,
  required Color ink,
  required Color muted,
}) {
  // Nastaliq needs generous line height so glyphs are never clipped.
  final double bodyHeight = isUrdu ? 1.9 : 1.5;
  final double headHeight = isUrdu ? 2.0 : 1.25;
  TextStyle base(
    String family,
    double size,
    FontWeight weight,
    double height,
    Color color,
  ) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color,
      );

  return TextTheme(
    displayLarge:
        base(displayFont, 30, FontWeight.w700, headHeight, ink), // hero
    headlineSmall:
        base(displayFont, 20, FontWeight.w700, headHeight, ink), // sections
    titleLarge:
        base(displayFont, 22, FontWeight.w700, headHeight, ink), // provider name
    titleMedium:
        base(displayFont, 16, FontWeight.w600, headHeight, ink), // card titles
    titleSmall:
        base(displayFont, 14, FontWeight.w600, headHeight, ink), // chips
    bodyLarge: base(bodyFont, 16, FontWeight.w400, bodyHeight, ink),
    bodyMedium: base(bodyFont, 14, FontWeight.w400, bodyHeight, ink),
    bodySmall: base(bodyFont, 12, FontWeight.w400, bodyHeight, muted),
    labelLarge: base(
        bodyFont, 15, FontWeight.w600, bodyHeight, ink), // buttons
  );
}

ThemeData buildAppTheme(Brightness brightness, String lang) {
  final c = AppColors.of(brightness);
  final isUrdu = lang == 'ur';
  final displayFont = isUrdu ? 'NotoNastaliqUrdu' : 'Sora';
  final bodyFont = isUrdu ? 'NotoNastaliqUrdu' : 'Manrope';

  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.brand,
    onPrimary: c.brandInkOn,
    secondary: c.brand,
    onSecondary: c.brandInkOn,
    surface: c.surface,
    onSurface: c.ink,
    surfaceContainerHighest: c.brandSoft,
    error: const Color(0xFFB3261E),
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.background,
    dividerColor: c.line,
    textTheme: _buildTextTheme(
      displayFont: displayFont,
      bodyFont: bodyFont,
      isUrdu: isUrdu,
      ink: c.ink,
      muted: c.muted,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      foregroundColor: c.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: displayFont,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: isUrdu ? 2.0 : 1.25,
        color: c.ink,
      ),
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: c.line),
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.brand,
        foregroundColor: c.brandInkOn,
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: TextStyle(
          fontFamily: bodyFont,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          height: isUrdu ? 1.9 : 1.4,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.ink,
        minimumSize: const Size(48, 52),
        side: BorderSide(color: c.line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.brand,
        minimumSize: const Size(48, 44),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: c.muted),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c.brand, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFB3261E)),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: BorderSide.none,
      labelStyle: TextStyle(
        fontFamily: bodyFont,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: isUrdu ? 1.9 : 1.4,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: c.surface,
      selectedItemColor: c.brand,
      unselectedItemColor: c.muted,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.ink,
      contentTextStyle: TextStyle(
        fontFamily: bodyFont,
        fontSize: 14,
        color: c.background,
        height: isUrdu ? 1.9 : 1.4,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.brand),
    iconTheme: IconThemeData(color: c.ink),
  );
}
