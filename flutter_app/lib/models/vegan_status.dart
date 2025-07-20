enum VeganStatus {
  vegan,
  nonVegan,
  maybeVegan,
}

extension VeganStatusExtension on VeganStatus {
  String toShortString() {
    switch (this) {
      case VeganStatus.vegan:
        return 'vegan';
      case VeganStatus.nonVegan:
        return 'non_vegan';
      case VeganStatus.maybeVegan:
        return 'maybe_vegan';
    }
  }

  String toApiString() {
    switch (this) {
      case VeganStatus.vegan:
        return 'VEGAN';
      case VeganStatus.nonVegan:
        return 'NON_VEGAN';
      case VeganStatus.maybeVegan:
        return 'MAYBE_VEGAN';
    }
  }

  static VeganStatus fromString(String? value) {
    switch (value) {
      case 'vegan':
        return VeganStatus.vegan;
      case 'non_vegan':
        return VeganStatus.nonVegan;
      case 'maybe_vegan':
        return VeganStatus.maybeVegan;
      default:
        return VeganStatus.maybeVegan;
    }
  }
}
