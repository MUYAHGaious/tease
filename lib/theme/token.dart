import 'package:flutter/material.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final double rSm, rMd, rLg;
  final double s1, s2, s3, s4, s6, s8;
  final double tapMin;
  const AppTokens({
    this.rSm = 8, this.rMd = 14, this.rLg = 24,
    this.s1 = 4, this.s2 = 8, this.s3 = 12, this.s4 = 16, this.s6 = 24, this.s8 = 32,
    this.tapMin = 48,
  });
  @override AppTokens copyWith({
    double? rSm,double? rMd,double? rLg,double? s1,double? s2,double? s3,double? s4,double? s6,double? s8,double? tapMin,
  }) => AppTokens(
    rSm: rSm ?? this.rSm, rMd: rMd ?? this.rMd, rLg: rLg ?? this.rLg,
    s1: s1 ?? this.s1, s2: s2 ?? this.s2, s3: s3 ?? this.s3, s4: s4 ?? this.s4, s6: s6 ?? this.s6, s8: s8 ?? this.s8,
    tapMin: tapMin ?? this.tapMin,
  );
  @override ThemeExtension<AppTokens> lerp(ThemeExtension<AppTokens>? o, double t) {
    if (o is! AppTokens) return this;
    double L(double a,double b)=>a+(b-a)*t;
    return AppTokens(
      rSm:L(rSm,o.rSm), rMd:L(rMd,o.rMd), rLg:L(rLg,o.rLg),
      s1:L(s1,o.s1), s2:L(s2,o.s2), s3:L(s3,o.s3), s4:L(s4,o.s4), s6:L(s6,o.s6), s8:L(s8,o.s8),
      tapMin:L(tapMin,o.tapMin),
    );
  }
}
extension XTokens on BuildContext { AppTokens get tokens => Theme.of(this).extension<AppTokens>()!; }
