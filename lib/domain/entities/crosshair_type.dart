/// The 10 crosshair styles offered by AIMORA.
///
/// Each entry maps to a localization key (`labelKey`) and a shape
/// identifier consumed by [CrosshairPainter] to decide how to render it.
enum CrosshairType {
  dot('type_dot'),
  cross('type_cross'),
  circle('type_circle'),
  tactical('type_tactical'),
  dynamic('type_dynamic'),
  sniper('type_sniper'),
  pro('type_pro'),
  minimal('type_minimal'),
  neon('type_neon'),
  cyber('type_cyber');

  const CrosshairType(this.labelKey);

  final String labelKey;

  static CrosshairType fromName(String name) {
    return CrosshairType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => CrosshairType.cross,
    );
  }
}
