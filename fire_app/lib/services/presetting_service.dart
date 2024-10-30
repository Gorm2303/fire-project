class PresettingService {
  static final Map<String, Map<String, String>> _presettings = {
    'None': {
      'principal': '0',
      'interestRate': '0',
      'duration': '0',
      'additionalAmount': '0',
    },
    'Medium Investment': {
      'principal': '5000',
      'duration': '25',
      'additionalAmount': '5000',
    },
    'Long Light Investment': {
      'principal': '2000',
      'duration': '40',
      'additionalAmount': '2000',
    }, 
    'High Investment': {
      'principal': '10000',
      'duration': '25',
      'additionalAmount': '10000',
    },
    'Slightly Extreme Investment': {
      'principal': '15000',
      'duration': '25',
      'additionalAmount': '15000',
    },
    'Extreme Investment': {
      'principal': '20000',
      'duration': '20',
      'additionalAmount': '20000',
    },
    'High Investment with Break': {
      'principal': '10000',
      'duration': '20',
      'additionalAmount': '10000',
      'breakPeriod': '10',
    },
    'Long Medium Investment': {
      'principal': '5000',
      'duration': '40',
      'additionalAmount': '5000',
    },
    'Aktiesparekonto': {
      'principal': '10000',
      'duration': '1',
      'additionalAmount': '10000',
      'breakPeriod': '24',
      'taxOption': 'Aktiesparekonto',
    },
    'Child Savings': {
      'principal': '5000',
      'duration': '21',
      'additionalAmount': '100',
    },
    'Pension': {
      'principal': '2000',
      'duration': '40',
      'additionalAmount': '2000',
    },
    'Child Pension Savings': {
      'principal': '5000',
      'duration': '10',
      'additionalAmount': '1000',
      'breakPeriod': '50',
    },
    'Money in the Bank': {
      'principal': '5000',
      'interestRate': '3.86',
      'duration': '25',
      'additionalAmount': '5000',
      'breakPeriod': '0',
    },
  };

  // Method to get a specific preset by key
  static Map<String, String> getPreset(String key) {
    return _presettings[key] ?? _presettings['None']!;
  }

  // Method to get all preset keys (useful for dropdowns)
  static List<String> getPresetKeys() {
    return _presettings.keys.toList();
  }
}
