import 'package:flutter/material.dart';

/// UniBuddy Brand Color Palette
class AppColors {
  // Prevent instantiation
  AppColors._();

  // 🟢 PRIMARY BRAND COLORS
  /// Primary Brand Color (AppBar / Main Nav)
  static const Color primaryBrand = Color(
    0xFF3D9E8C,
  ); // Light Teal (Main Branch)

  /// Primary Dark Variant
  static const Color primaryDark = Color(0xFF2E8B7D); // Dark Teal Variant

  /// Accent / CTA Buttons
  static const Color accent = Color(0xFF14B8A6); // Bright Teal

  /// Accent Light Hover
  static const Color accentLight = Color(0xFF2DD4BF); // Soft Teal

  // 🎨 BACKGROUND COLORS
  /// Main Background (60%)
  static const Color backgroundLight = Color(0xFFF0FDFA); // Light Teal Tint

  /// Card Background
  static const Color cardBackground = Color(0xFFFFFFFF); // White

  /// Section Divider / Border
  static const Color border = Color(0xFFE2E8F0); // Light Gray

  // 📝 TEXT COLORS
  /// Primary Text
  static const Color textPrimary = Color(0xFF1E293B); // Dark Slate

  /// Secondary Text
  static const Color textSecondary = Color(0xFF64748B); // Lighter Slate

  /// Disabled Text
  static const Color textDisabled = Color(0xFFA3B1C2); // Softer Gray

  /// Text on Dark Background
  static const Color textOnDark = Color(0xFFFFFFFF); // White

  // 🔴 STATUS COLORS
  /// Success Color
  static const Color success = Color(0xFF10B981); // Green

  /// Warning Color
  static const Color warning = Color(0xFFF59E0B); // Amber

  /// Error Color
  static const Color error = Color(0xFFEF4444); // Red

  /// Info Color
  static const Color info = Color(0xFF3B82F6); // Blue

  // Opacity variants
  static Color primaryBrandWithOpacity(double opacity) =>
      primaryBrand.withValues(alpha: opacity);
  static Color accentWithOpacity(double opacity) =>
      accent.withValues(alpha: opacity);
  static Color backgroundWithOpacity(double opacity) =>
      backgroundLight.withValues(alpha: opacity);
}
