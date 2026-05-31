// Re-export everything from the original so callers get a single import.
export 'delivery_math_utils.dart';

/// Interpolates between two angles (in degrees) through the shortest arc.
/// [t] ranges from 0.0 (returns [from]) to 1.0 (returns [to]).
double lerpAngle(double from, double to, double t) {
  double diff = (to - from) % 360;
  if (diff > 180) diff -= 360;
  if (diff < -180) diff += 360;
  return (from + diff * t) % 360;
}
