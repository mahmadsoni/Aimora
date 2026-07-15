import 'package:flutter_test/flutter_test.dart';
import 'package:aimora/data/models/crosshair_model.dart';
import 'package:aimora/domain/entities/crosshair_type.dart';

void main() {
  group('CrosshairConfig', () {
    test('defaults() returns a sane cross configuration', () {
      final CrosshairConfig config = CrosshairConfig.defaults();
      expect(config.type, CrosshairType.cross);
      expect(config.opacity, 1.0);
      expect(config.size, greaterThan(0));
    });

    test('toJson / fromJson round-trip preserves all fields', () {
      const CrosshairConfig original = CrosshairConfig(
        type: CrosshairType.neon,
        colorValue: 0xFFFF0000,
        size: 55,
        thickness: 4,
        gap: 12,
        opacity: 0.8,
        outline: false,
      );
      final Map<String, dynamic> json = original.toJson();
      final CrosshairConfig restored = CrosshairConfig.fromJson(json);
      expect(restored, original);
    });

    test('copyWith overrides only the given fields', () {
      final CrosshairConfig base = CrosshairConfig.defaults();
      final CrosshairConfig updated = base.copyWith(size: 99);
      expect(updated.size, 99);
      expect(updated.type, base.type);
      expect(updated.colorValue, base.colorValue);
    });

    test('CrosshairType.fromName falls back to cross for unknown names', () {
      expect(CrosshairType.fromName('does_not_exist'), CrosshairType.cross);
      expect(CrosshairType.fromName('sniper'), CrosshairType.sniper);
    });
  });
}
