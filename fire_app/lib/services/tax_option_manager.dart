import 'package:flutter/foundation.dart';
import '../models/tax_option.dart';

class TaxOptionManager extends ChangeNotifier {
  late TaxOption _currentTaxOption;
  bool _isCustomTaxRate = false;
  bool _isCustomPredefined = false;
  final List<TaxOption> _taxOptions;
  TaxOption? _lastPredefinedOption;

  TaxOptionManager({
    required TaxOption initialOption,
    required List<TaxOption> taxOptions,
  })  : _currentTaxOption = initialOption,
        _taxOptions = taxOptions {
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

  /// Switches to a predefined tax option and stores it as the last known predefined option
  void switchToPredefined(TaxOption newOption) {
    _isCustomTaxRate = false;
    _isCustomPredefined = false;
    _currentTaxOption = newOption;
    _lastPredefinedOption = newOption;  // Remember the last predefined option
    notifyListeners();  // Notify listeners to update UI
  }

  /// Switches to a custom tax rate
  void switchToCustomRate(double customRate, bool isNotionallyTaxed, bool useExemption, bool useProgressionLimit) {
      _isCustomTaxRate = true;
      _isCustomPredefined = false;
      _currentTaxOption = TaxOption(
        customRate,
        'Custom ($customRate%)',
        isNotionallyTaxed: isNotionallyTaxed,
        useTaxExemptionCard: useExemption,
        useTaxProgressionLimit: useProgressionLimit,
      );
      notifyListeners();  // Notify listeners to update UI
    }

  /// Switches to a custom predefined tax option
  void switchToCustomPredefined(bool isNotionallyTaxed, bool useExemption, bool useProgressionLimit) {
    if (_isCustomTaxRate) return;  // Prevent custom predefined option when a custom rate is active
    _isCustomPredefined = true;
    _currentTaxOption = TaxOption(
      _currentTaxOption.ratePercentage,  // Keep predefined rate
      'Custom',
      isNotionallyTaxed: isNotionallyTaxed,
      useTaxExemptionCard: useExemption,
      useTaxProgressionLimit: useProgressionLimit,
    );
    notifyListeners();  // Notify listeners to update UI
  }

  /// Switches back to the last known predefined option
  void switchBackToLastPredefined() {
    if (_lastPredefinedOption != null) {
      _isCustomTaxRate = false;
      _isCustomPredefined = false;
      _currentTaxOption = _lastPredefinedOption!;
      notifyListeners();  // Notify listeners to update UI
    }
  }

  /// Toggles tax exemption
  void toggleTaxExemption(bool useExemption) {
    if (_isCustomTaxRate) {
      switchToCustomRate(
        _currentTaxOption.ratePercentage,
        _currentTaxOption.isNotionallyTaxed,
        useExemption,
        _currentTaxOption.useTaxProgressionLimit,
      );
    } else if (existsPredefinedOption(
        _currentTaxOption.ratePercentage, _currentTaxOption.isNotionallyTaxed, useExemption, _currentTaxOption.useTaxProgressionLimit)) {
      TaxOption matchedOption = findPredefinedOption(
        _currentTaxOption.ratePercentage, _currentTaxOption.isNotionallyTaxed, useExemption, _currentTaxOption.useTaxProgressionLimit)!;
      switchToPredefined(matchedOption);
    } else {
      switchToCustomPredefined(_currentTaxOption.isNotionallyTaxed, useExemption, _currentTaxOption.useTaxProgressionLimit);
    }
  }

  /// Toggles progression limit
  void toggleTaxProgressionLimit(bool useProgressionLimit) {
    if (_isCustomTaxRate) {
      switchToCustomRate(
        _currentTaxOption.ratePercentage,
        _currentTaxOption.isNotionallyTaxed, // Use progression limit here
        _currentTaxOption.useTaxExemptionCard,
        useProgressionLimit, // Use progression limit here
      );
    } else if (existsPredefinedOption(
        _currentTaxOption.ratePercentage, _currentTaxOption.isNotionallyTaxed, _currentTaxOption.useTaxExemptionCard, useProgressionLimit)) {
      TaxOption matchedOption = findPredefinedOption(
        _currentTaxOption.ratePercentage, _currentTaxOption.isNotionallyTaxed, _currentTaxOption.useTaxExemptionCard, useProgressionLimit)!;
      switchToPredefined(matchedOption);
    } else {
      switchToCustomPredefined(_currentTaxOption.isNotionallyTaxed, _currentTaxOption.useTaxExemptionCard, useProgressionLimit);
    }
  }

  /// Toggles tax type
  void toggleTaxType(bool isNotionallyTaxed) {
    if (_isCustomTaxRate) {
      switchToCustomRate(
        _currentTaxOption.ratePercentage,
        isNotionallyTaxed,
        _currentTaxOption.useTaxExemptionCard,
        _currentTaxOption.useTaxProgressionLimit,
      );
    } else if (existsPredefinedOption(_currentTaxOption.ratePercentage, isNotionallyTaxed,_currentTaxOption.useTaxExemptionCard, _currentTaxOption.useTaxProgressionLimit)) {
      TaxOption matchedOption = findPredefinedOption(
        _currentTaxOption.ratePercentage, isNotionallyTaxed, _currentTaxOption.useTaxExemptionCard, _currentTaxOption.useTaxProgressionLimit)!;
      switchToPredefined(matchedOption);
    } else {
      switchToCustomPredefined(isNotionallyTaxed, _currentTaxOption.useTaxExemptionCard, _currentTaxOption.useTaxProgressionLimit);
    }
  }

  bool existsPredefinedOption(double ratePercentage, bool isNotionallyTaxed, bool useExemption, bool useProgressionLimit) {
    return _taxOptions.any((option) =>
        option.ratePercentage == ratePercentage &&
        option.isNotionallyTaxed == isNotionallyTaxed &&
        option.useTaxExemptionCard == useExemption &&
        option.useTaxProgressionLimit == useProgressionLimit);
  }

  TaxOption? findPredefinedOption(double ratePercentage, bool isNotionallyTaxed, bool useExemption, bool useProgressionLimit) {
    try {
      return _taxOptions.firstWhere((option) =>
          option.ratePercentage == ratePercentage &&
          option.isNotionallyTaxed == isNotionallyTaxed &&
          option.useTaxExemptionCard == useExemption &&
          option.useTaxProgressionLimit == useProgressionLimit);
    } catch (e) {
      return null;
    }
  }

  TaxOption? findOptionByDescription(String description) {
    try {
      return _taxOptions.firstWhere((option) => option.description == description);
    } catch (e) {
      return null;
    }
  }
}
