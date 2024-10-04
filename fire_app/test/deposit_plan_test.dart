import 'package:fire_app/models/tax_option.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fire_app/models/deposit_plan.dart'; // Import your model here
import 'dart:math';

void main() {
  final List<TaxOption> taxOptions = [
    TaxOption(42.0, 'Tax On Sale', isNotionallyTaxed: false, useTaxExemptionCardAndThreshold: true),
    TaxOption(42.0, 'Tax Every Year', isNotionallyTaxed: true, useTaxExemptionCardAndThreshold: false),
    TaxOption(17.0, 'Aktiesparekonto', isNotionallyTaxed: true, useTaxExemptionCardAndThreshold: false),
    TaxOption(15.3, 'Pension PAL-skat', isNotionallyTaxed: true, useTaxExemptionCardAndThreshold: false),
    TaxOption(42.0, 'Custom 1', isNotionallyTaxed: true, useTaxExemptionCardAndThreshold: true),
    TaxOption(42.0, 'Custom 2', isNotionallyTaxed: false, useTaxExemptionCardAndThreshold: false),
  ];

  List<DepositPlan> depositPlans = [];
  for (int i = 0; i < taxOptions.length; i++) {
    depositPlans.add(
      DepositPlan(
        principal: 10000.0,
        interestRate: 7,
        duration: 25,
        additionalAmount: 10000.0,
        contributionFrequency: 'Monthly',
        selectedTaxOption: taxOptions[i],
      ),
    );
  }

  group('Tax Calculation Tests', () {
    test('No earnings should return 0 tax', () {
      const earnings = 0.0;
      for (int i = 0; i < depositPlans.length; i++) {
        final result = depositPlans[i].calculateTaxOnEarnings(earnings); // Make this method public in your DepositPlan
        expect(result, 0.0);
      }
    });

    test('Earnings below tax exemption should return 0 tax for applicable tax options', () {
      const earnings = 10000.0;
      for (int i = 0; i < depositPlans.length; i++) {
        final result = depositPlans[i].calculateTaxOnEarnings(earnings); // Public method

        if (depositPlans[i].selectedTaxOption.useTaxExemptionCardAndThreshold) {
          const expectedTax = 0.0; // No tax for earnings below threshold when using exemption
          expect(result, expectedTax);
        } else {
          final expectedTax = earnings * depositPlans[i].selectedTaxOption.ratePercentage / 100;
          expect(result, expectedTax); // Apply tax directly when not using exemption
        }
      }
    });

    test('Earnings below threshold but above tax exemption should return correct tax for applicable options', () {
      const earnings = TaxOption.taxExemptionCard + TaxOption.threshold - 1000 ; // Slightly below threshold for exemption
      for (int i = 0; i < depositPlans.length; i++) {
        final result = depositPlans[i].calculateTaxOnEarnings(earnings);

        if (depositPlans[i].selectedTaxOption.useTaxExemptionCardAndThreshold) {
          const expectedTax = (earnings - TaxOption.taxExemptionCard) * TaxOption.lowerTaxRate/100; // Tax calculation for below threshold
          expect(result, expectedTax);
        } else {
          final expectedTax = earnings * depositPlans[i].selectedTaxOption.ratePercentage / 100;
          expect(result, expectedTax); // Apply tax directly when not using exemption
        }
      }
    });

    test('Earnings above threshold with tax exemption should return correct tax for applicable options', () {
      const earnings = 1050000.0; // Well above threshold
      for (int i = 0; i < depositPlans.length; i++) {
        final result = depositPlans[i].calculateTaxOnEarnings(earnings);

        if (depositPlans[i].selectedTaxOption.useTaxExemptionCardAndThreshold) {
          final expectedTax = (TaxOption.threshold * TaxOption.lowerTaxRate/100) 
          + ((earnings - TaxOption.taxExemptionCard - TaxOption.threshold) * depositPlans[i].selectedTaxOption.ratePercentage/100); // Tax calculation for above threshold
          expect(result, expectedTax);
        } else {
          final expectedTax = earnings * depositPlans[i].selectedTaxOption.ratePercentage / 100;
          expect(result, expectedTax); // Apply tax directly when not using exemption
        }
      }
    });

    test('Negative earnings should return 0 tax', () {
      const earnings = -5000.0;
      for (int i = 0; i < depositPlans.length; i++) {
        final result = depositPlans[i].calculateTaxOnEarnings(earnings);
        expect(result, 0.0);
      }
    });

    test('Earnings without tax exemption should apply default rate', () {
      const earnings = 12000.0;
      for (int i = 0; i < depositPlans.length; i++) {
        final result = depositPlans[i].calculateTaxOnEarnings(earnings);
        if (!depositPlans[i].selectedTaxOption.useTaxExemptionCardAndThreshold) {
          final expectedTax = 12000.0 * depositPlans[i].selectedTaxOption.ratePercentage / 100;
          expect(result, expectedTax);
        }
      }
    });
  });
group('Compounding Tests', () {
  test('No interest should return 0 compounding', () {
    final depositPlan = DepositPlan(
      principal: 10000.0,
      interestRate: 0.0, // No interest
      duration: 25,
      additionalAmount: 10000.0, // No contributions
      contributionFrequency: 'Monthly',
      selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: false, useTaxExemptionCardAndThreshold: false),
    );
    final result = depositPlan.calculateCompounding(12); // 12 periods (monthly)
    expect(result, 0.0);
  });

  test('No additionalAmount should return the correct compounding', () {
    final depositPlan = DepositPlan(
      principal: 10000.0,
      interestRate: 7.0, // No interest
      duration: 25,
      additionalAmount: 0.0,
      contributionFrequency: 'Monthly',
      selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: false, useTaxExemptionCardAndThreshold: false),
    );
    
    const contributionPeriods = 1;
    final result = depositPlan.calculateCompounding(contributionPeriods); // 12 periods (monthly)

    // Initialize expected compounding for the principal
    double expectedCompounding = 0;
    expectedCompounding += depositPlan.principal * (depositPlan.interestRate / 100);
    expect(result, expectedCompounding);
  });

  test('Basic compounding with contributions should return correct amount', () {
    final depositPlan = depositPlans[0]; // Use the first deposit plan
    const contributionPeriods = 12;
    final result = depositPlan.calculateCompounding(contributionPeriods); // 12 periods (monthly)

    // Initialize expected compounding for the principal
    double expectedCompounding = depositPlan.principal * (depositPlan.interestRate / 100);

    // Now calculate expected compounding for each contribution
    for (int period = 1; period <= contributionPeriods; period++) {
// Add the contribution
      int periodsLeft = contributionPeriods - period;
      
      // Only compound the contribution for the periods left
      expectedCompounding += depositPlan.additionalAmount * (depositPlan.interestRate / 100) * periodsLeft / contributionPeriods;
    }

    expect(result, expectedCompounding);
  });

    test('Compounding with no contributions but with interest', () {
      final depositPlan = DepositPlan(
        principal: 10000.0,
        interestRate: 7.0, // 7% interest
        duration: 25,
        additionalAmount: 0.0, // No contributions
        contributionFrequency: 'Monthly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: false, useTaxExemptionCardAndThreshold: false),
      );
      final result = depositPlan.calculateCompounding(12); // 12 periods
      final expectedCompounding = depositPlan.principal * 0.07; // Interest on principal only
      expect(result, expectedCompounding);
    });
  });
}