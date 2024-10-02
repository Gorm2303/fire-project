import '../models/tax_option.dart';

class TaxOptionManager {
  late TaxOption _currentTaxOption;
  bool _isCustomTaxRate = false; // For a truly custom tax rate
  bool _isCustomPredefined = false; // For a custom version of a predefined tax option (without changing the rate)
  final List<TaxOption> _taxOptions;
  TaxOption? _lastPredefinedOption; // Store the last predefined option before custom rate switch

  TaxOptionManager({
    required TaxOption initialOption,
    required List<TaxOption> taxOptions,
  })  : _currentTaxOption = initialOption,
        _taxOptions = taxOptions,
        _isCustomPredefined = false {
    // Initialize the last predefined option with the initial one
    _lastPredefinedOption = initialOption;
  }

  TaxOption get currentOption => _currentTaxOption;
  List<TaxOption> get taxOptions => _taxOptions;
  bool get isCustomTaxRate => _isCustomTaxRate;
  bool get isCustomPredefined => _isCustomPredefined;

  /// Returns all tax options including the custom one if active
  List<TaxOption> get allTaxOptions {
    if (_isCustomPredefined || _isCustomTaxRate) {
      return [..._taxOptions, _currentTaxOption];
    }
    return _taxOptions;
  }

  /// Checks if a predefined tax option exists with the given criteria
  bool existsPredefinedOption(double ratePercentage, bool isNotionallyTaxed, bool useExemption) {
    return _taxOptions.any((option) =>
        option.ratePercentage == ratePercentage &&
        option.isNotionallyTaxed == isNotionallyTaxed &&
        option.useTaxExemptionCardAndThreshold == useExemption);
  }

  /// Finds a predefined tax option matching the given criteria
  TaxOption? findPredefinedOption(double ratePercentage, bool isNotionallyTaxed, bool useExemption) {
    try {
      return _taxOptions.firstWhere((option) =>
          option.ratePercentage == ratePercentage &&
          option.isNotionallyTaxed == isNotionallyTaxed &&
          option.useTaxExemptionCardAndThreshold == useExemption);
    } catch (e) {
      return null;
    }
  }

  /// Switches to a predefined tax option and stores it as the last known predefined option
  void switchToPredefined(TaxOption newOption) {
    _isCustomTaxRate = false;
    _isCustomPredefined = false;
    _currentTaxOption = newOption;
    _lastPredefinedOption = newOption; // Remember the last predefined option
  }

  /// Switches to a custom tax rate
  void switchToCustomRate(double customRate, bool isNotionallyTaxed, bool useExemption) {
    _isCustomTaxRate = true;
    _isCustomPredefined = false;
    _currentTaxOption = TaxOption(
      customRate,
      'Custom ($customRate%)',
      isNotionallyTaxed,
      useExemption,
    );
  }

  /// Switches to a custom predefined tax option (only when the rate is not custom)
  void switchToCustomPredefined(bool isNotionallyTaxed, bool useExemption) {
    if (_isCustomTaxRate) {
      // Prevent custom predefined option when a custom rate is active
      return;
    }

    _isCustomPredefined = true;
    _currentTaxOption = TaxOption(
      _currentTaxOption.ratePercentage, // Keep predefined rate
      'Custom',
      isNotionallyTaxed,
      useExemption,
    );
  }

  /// Switches back to the last known predefined option
  void switchBackToLastPredefined() {
    if (_lastPredefinedOption != null) {
      _isCustomTaxRate = false;
      _isCustomPredefined = false;
      _currentTaxOption = _lastPredefinedOption!;
    }
  }

  /// Toggles tax exemption and switches to predefined or custom accordingly
  void toggleTaxExemption(bool useExemption) {
    if (_isCustomTaxRate) {
      // If using a custom tax rate, allow changing the exemption but keep the rate custom
      switchToCustomRate(
        _currentTaxOption.ratePercentage,
        _currentTaxOption.isNotionallyTaxed,
        useExemption,
      );
    } else if (existsPredefinedOption(
        _currentTaxOption.ratePercentage, _currentTaxOption.isNotionallyTaxed, useExemption)) {
      TaxOption matchedOption = findPredefinedOption(
          _currentTaxOption.ratePercentage, _currentTaxOption.isNotionallyTaxed, useExemption)!;
      switchToPredefined(matchedOption);
    } else {
      switchToCustomPredefined(_currentTaxOption.isNotionallyTaxed, useExemption);
    }
  }

  /// Toggles tax type and switches to predefined or custom accordingly
  void toggleTaxType(bool isNotionallyTaxed) {
    if (_isCustomTaxRate) {
      // If using a custom tax rate, allow changing the tax type but keep the rate custom
      switchToCustomRate(
        _currentTaxOption.ratePercentage,
        isNotionallyTaxed,
        _currentTaxOption.useTaxExemptionCardAndThreshold,
      );
    } else if (existsPredefinedOption(
        _currentTaxOption.ratePercentage, isNotionallyTaxed, _currentTaxOption.useTaxExemptionCardAndThreshold)) {
      TaxOption matchedOption = findPredefinedOption(
          _currentTaxOption.ratePercentage, isNotionallyTaxed, _currentTaxOption.useTaxExemptionCardAndThreshold)!;
      switchToPredefined(matchedOption);
    } else {
      switchToCustomPredefined(isNotionallyTaxed, _currentTaxOption.useTaxExemptionCardAndThreshold);
    }
  }
}
