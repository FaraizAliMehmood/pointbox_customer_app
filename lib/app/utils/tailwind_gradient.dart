import 'package:flutter/material.dart';

/// Minimal Tailwind CSS color palette (shades 50-900) for the hues used
/// by company tier gradients (e.g. "from-purple-600 to-indigo-600").
const Map<String, Map<int, Color>> _tailwindPalette = {
  'gray': {
    50: Color(0xFFF9FAFB), 100: Color(0xFFF3F4F6), 200: Color(0xFFE5E7EB),
    300: Color(0xFFD1D5DB), 400: Color(0xFF9CA3AF), 500: Color(0xFF6B7280),
    600: Color(0xFF4B5563), 700: Color(0xFF374151), 800: Color(0xFF1F2937),
    900: Color(0xFF111827),
  },
  'slate': {
    50: Color(0xFFF8FAFC), 100: Color(0xFFF1F5F9), 200: Color(0xFFE2E8F0),
    300: Color(0xFFCBD5E1), 400: Color(0xFF94A3B8), 500: Color(0xFF64748B),
    600: Color(0xFF475569), 700: Color(0xFF334155), 800: Color(0xFF1E293B),
    900: Color(0xFF0F172A),
  },
  'red': {
    50: Color(0xFFFEF2F2), 100: Color(0xFFFEE2E2), 200: Color(0xFFFECACA),
    300: Color(0xFFFCA5A5), 400: Color(0xFFF87171), 500: Color(0xFFEF4444),
    600: Color(0xFFDC2626), 700: Color(0xFFB91C1C), 800: Color(0xFF991B1B),
    900: Color(0xFF7F1D1D),
  },
  'orange': {
    50: Color(0xFFFFF7ED), 100: Color(0xFFFFEDD5), 200: Color(0xFFFED7AA),
    300: Color(0xFFFDBA74), 400: Color(0xFFFB923C), 500: Color(0xFFF97316),
    600: Color(0xFFEA580C), 700: Color(0xFFC2410C), 800: Color(0xFF9A3412),
    900: Color(0xFF7C2D12),
  },
  'amber': {
    50: Color(0xFFFFFBEB), 100: Color(0xFFFEF3C7), 200: Color(0xFFFDE68A),
    300: Color(0xFFFCD34D), 400: Color(0xFFFBBF24), 500: Color(0xFFF59E0B),
    600: Color(0xFFD97706), 700: Color(0xFFB45309), 800: Color(0xFF92400E),
    900: Color(0xFF78350F),
  },
  'yellow': {
    50: Color(0xFFFEFCE8), 100: Color(0xFFFEF9C3), 200: Color(0xFFFEF08A),
    300: Color(0xFFFDE047), 400: Color(0xFFFACC15), 500: Color(0xFFEAB308),
    600: Color(0xFFCA8A04), 700: Color(0xFFA16207), 800: Color(0xFF854D0E),
    900: Color(0xFF713F12),
  },
  'lime': {
    50: Color(0xFFF7FEE7), 100: Color(0xFFECFCCB), 200: Color(0xFFD9F99D),
    300: Color(0xFFBEF264), 400: Color(0xFFA3E635), 500: Color(0xFF84CC16),
    600: Color(0xFF65A30D), 700: Color(0xFF4D7C0F), 800: Color(0xFF3F6212),
    900: Color(0xFF365314),
  },
  'green': {
    50: Color(0xFFF0FDF4), 100: Color(0xFFDCFCE7), 200: Color(0xFFBBF7D0),
    300: Color(0xFF86EFAC), 400: Color(0xFF4ADE80), 500: Color(0xFF22C55E),
    600: Color(0xFF16A34A), 700: Color(0xFF15803D), 800: Color(0xFF166534),
    900: Color(0xFF14532D),
  },
  'emerald': {
    50: Color(0xFFECFDF5), 100: Color(0xFFD1FAE5), 200: Color(0xFFA7F3D0),
    300: Color(0xFF6EE7B7), 400: Color(0xFF34D399), 500: Color(0xFF10B981),
    600: Color(0xFF059669), 700: Color(0xFF047857), 800: Color(0xFF065F46),
    900: Color(0xFF064E3B),
  },
  'teal': {
    50: Color(0xFFF0FDFA), 100: Color(0xFFCCFBF1), 200: Color(0xFF99F6E4),
    300: Color(0xFF5EEAD4), 400: Color(0xFF2DD4BF), 500: Color(0xFF14B8A6),
    600: Color(0xFF0D9488), 700: Color(0xFF0F766E), 800: Color(0xFF115E59),
    900: Color(0xFF134E4A),
  },
  'cyan': {
    50: Color(0xFFECFEFF), 100: Color(0xFFCFFAFE), 200: Color(0xFFA5F3FC),
    300: Color(0xFF67E8F9), 400: Color(0xFF22D3EE), 500: Color(0xFF06B6D4),
    600: Color(0xFF0891B2), 700: Color(0xFF0E7490), 800: Color(0xFF155E75),
    900: Color(0xFF164E63),
  },
  'sky': {
    50: Color(0xFFF0F9FF), 100: Color(0xFFE0F2FE), 200: Color(0xFFBAE6FD),
    300: Color(0xFF7DD3FC), 400: Color(0xFF38BDF8), 500: Color(0xFF0EA5E9),
    600: Color(0xFF0284C7), 700: Color(0xFF0369A1), 800: Color(0xFF075985),
    900: Color(0xFF0C4A6E),
  },
  'blue': {
    50: Color(0xFFEFF6FF), 100: Color(0xFFDBEAFE), 200: Color(0xFFBFDBFE),
    300: Color(0xFF93C5FD), 400: Color(0xFF60A5FA), 500: Color(0xFF3B82F6),
    600: Color(0xFF2563EB), 700: Color(0xFF1D4ED8), 800: Color(0xFF1E40AF),
    900: Color(0xFF1E3A8A),
  },
  'indigo': {
    50: Color(0xFFEEF2FF), 100: Color(0xFFE0E7FF), 200: Color(0xFFC7D2FE),
    300: Color(0xFFA5B4FC), 400: Color(0xFF818CF8), 500: Color(0xFF6366F1),
    600: Color(0xFF4F46E5), 700: Color(0xFF4338CA), 800: Color(0xFF3730A3),
    900: Color(0xFF312E81),
  },
  'violet': {
    50: Color(0xFFF5F3FF), 100: Color(0xFFEDE9FE), 200: Color(0xFFDDD6FE),
    300: Color(0xFFC4B5FD), 400: Color(0xFFA78BFA), 500: Color(0xFF8B5CF6),
    600: Color(0xFF7C3AED), 700: Color(0xFF6D28D9), 800: Color(0xFF5B21B6),
    900: Color(0xFF4C1D95),
  },
  'purple': {
    50: Color(0xFFFAF5FF), 100: Color(0xFFF3E8FF), 200: Color(0xFFE9D5FF),
    300: Color(0xFFD8B4FE), 400: Color(0xFFC084FC), 500: Color(0xFFA855F7),
    600: Color(0xFF9333EA), 700: Color(0xFF7E22CE), 800: Color(0xFF6B21A8),
    900: Color(0xFF581C87),
  },
  'fuchsia': {
    50: Color(0xFFFDF4FF), 100: Color(0xFFFAE8FF), 200: Color(0xFFF5D0FE),
    300: Color(0xFFF0ABFC), 400: Color(0xFFE879F9), 500: Color(0xFFD946EF),
    600: Color(0xFFC026D3), 700: Color(0xFFA21CAF), 800: Color(0xFF86198F),
    900: Color(0xFF701A75),
  },
  'pink': {
    50: Color(0xFFFDF2F8), 100: Color(0xFFFCE7F3), 200: Color(0xFFFBCFE8),
    300: Color(0xFFF9A8D4), 400: Color(0xFFF472B6), 500: Color(0xFFEC4899),
    600: Color(0xFFDB2777), 700: Color(0xFFBE185D), 800: Color(0xFF9D174D),
    900: Color(0xFF831843),
  },
  'rose': {
    50: Color(0xFFFFF1F2), 100: Color(0xFFFFE4E6), 200: Color(0xFFFECDD3),
    300: Color(0xFFFDA4AF), 400: Color(0xFFFB7185), 500: Color(0xFFF43F5E),
    600: Color(0xFFE11D48), 700: Color(0xFFBE123C), 800: Color(0xFF9F1239),
    900: Color(0xFF881337),
  },
};

/// Parses a Tailwind gradient utility string, e.g. "from-purple-600 to-indigo-600"
/// (optionally with a "via-color-shade" stop), into a Flutter [LinearGradient].
/// Returns null when the string can't be parsed (unknown hue, wrong shape, etc).
LinearGradient? parseTailwindGradient(String? classes) {
  if (classes == null || classes.trim().isEmpty) return null;

  final matches = RegExp(r'(from|via|to)-([a-z]+)-(\d{2,3})').allMatches(classes);
  final stops = <String, Color>{};
  for (final m in matches) {
    final keyword = m.group(1)!;
    final hue = m.group(2)!;
    final shade = int.tryParse(m.group(3)!);
    final color = shade == null ? null : _tailwindPalette[hue]?[shade];
    if (color != null) stops[keyword] = color;
  }

  final colors = [
    if (stops['from'] != null) stops['from']!,
    if (stops['via'] != null) stops['via']!,
    if (stops['to'] != null) stops['to']!,
  ];

  if (colors.length < 2) return null;

  return LinearGradient(
    colors: colors,
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
