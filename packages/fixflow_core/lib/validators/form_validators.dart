class FormValidators {
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName je obavezno polje.';
    }
    return null;
  }

  static String? length(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) return null;
    if (min != null && value.length < min) {
      return 'Minimalno $min karaktera.';
    }
    if (max != null && value.length > max) {
      return 'Maksimalno $max karaktera.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    // Allow standard emails and simple identifiers (for test/dev credentials)
    final emailRegex = RegExp(r'^[\w\.-]+(@[\w\.-]+\.\w{2,})?$');
    if (!emailRegex.hasMatch(value)) {
      return 'Unesite ispravnu email adresu.';
    }
    return null;
  }

  static String? range(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) return null;
    final number = double.tryParse(value);
    if (number == null) return 'Unesite ispravan broj.';
    if (min != null && number < min) return 'Minimalna vrijednost je $min.';
    if (max != null && number > max) return 'Maksimalna vrijednost je $max.';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    final phoneRegex = RegExp(r'^\+?[\d\s-]{8,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Unesite ispravan broj telefona.';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) return 'Lozinka je obavezna.';
    if (value.length < minLength) {
      return 'Lozinka mora imati najmanje $minLength karaktera.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? original) {
    if (value == null || value.isEmpty) return 'Potvrdite lozinku.';
    if (value != original) return 'Lozinke se ne poklapaju.';
    return null;
  }

  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
