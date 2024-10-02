import 'package:flutter/material.dart';
import '../services/tax_option_manager.dart';

class TaxOptionProvider with ChangeNotifier {
  final TaxOptionManager _taxOptionManager;

  TaxOptionProvider(this._taxOptionManager);

  TaxOptionManager get manager => _taxOptionManager;

  void updateTaxOption() {
    notifyListeners();
  }
}
