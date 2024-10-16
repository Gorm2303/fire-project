import 'package:fire_app/models/tax_option.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fire_app/models/deposit_plan.dart'; // Import your model here

void main() {
  final List<TaxOption> taxOptions = [
    TaxOption(42.0, 'Tax On Sale', isNotionallyTaxed: false, useTaxExemptionCard: true, useTaxProgressionLimit: true),
    TaxOption(42.0, 'Tax On Sale', isNotionallyTaxed: false, useTaxExemptionCard: false, useTaxProgressionLimit: false),
    TaxOption(42.0, 'Tax On Sale', isNotionallyTaxed: false, useTaxExemptionCard: true, useTaxProgressionLimit: false),
    TaxOption(42.0, 'Tax On Sale', isNotionallyTaxed: false, useTaxExemptionCard: false, useTaxProgressionLimit: true),
    TaxOption(42.0, 'Tax Every Year', isNotionallyTaxed: true, useTaxExemptionCard: false, useTaxProgressionLimit: false),
    TaxOption(42.0, 'Tax Every Year', isNotionallyTaxed: true, useTaxExemptionCard: true, useTaxProgressionLimit: false),
    TaxOption(42.0, 'Tax Every Year', isNotionallyTaxed: true, useTaxExemptionCard: false, useTaxProgressionLimit: true),
    TaxOption(42.0, 'Tax Every Year', isNotionallyTaxed: true, useTaxExemptionCard: true, useTaxProgressionLimit: true),
    TaxOption(17.0, 'Aktiesparekonto', isNotionallyTaxed: true, useTaxExemptionCard: false, useTaxProgressionLimit: false),
    TaxOption(15.3, 'Pension PAL-skat', isNotionallyTaxed: true, useTaxExemptionCard: false, useTaxProgressionLimit: false),
  ];


  List<DepositPlan> depositPlans = [];
  for (TaxOption taxOption in taxOptions) {
    depositPlans.add(
      DepositPlan(
        principal: 10000.0,
        interestRate: 7,
        duration: 25,
        additionalContribution: 10000.0,
        contributionFrequency: 'Monthly',
        selectedTaxOption: taxOption,
      ),
    );
  }

  group('Tax Calculation Tests', () {
    test('No earnings should return 0 tax', () {
      const earnings = 0.0;
      for (DepositPlan depositPlan in depositPlans) {
        final result = depositPlan.calculateTaxOnEarnings(earnings); // Make this method public in your DepositPlan
        expect(result, 0.0);
      }
    });

    test('Earnings below tax exemption should return 0 tax for applicable tax options', () {
      const earnings = TaxOption.taxExemptionCard - 1000; // Slightly below threshold for exemption
      for (DepositPlan depositPlan in depositPlans) {
        final result = depositPlan.calculateTaxOnEarnings(earnings); // Public method

        if (depositPlan.selectedTaxOption.useTaxExemptionCard) {
          const expectedTax = 0.0; // No tax for earnings below threshold when using exemption
          expect(result, expectedTax);
        } else if (!depositPlan.selectedTaxOption.useTaxProgressionLimit || depositPlan.selectedTaxOption.ratePercentage < TaxOption.lowerTaxRate) {
          final expectedTax = earnings * depositPlan.selectedTaxOption.ratePercentage / 100;
          expect(result, expectedTax); // Apply tax directly when not using exemption
        } else {
          const expectedTax = earnings * TaxOption.lowerTaxRate / 100;
          expect(result, expectedTax);
        }
      }
    });

    test('Earnings below threshold but above tax exemption should return correct tax for applicable options', () {
      const earnings = TaxOption.taxExemptionCard + TaxOption.taxProgressionLimit - 1000; // Slightly below threshold for exemption
      for (DepositPlan depositPlan in depositPlans) {
        final selectedTaxOption = depositPlan.selectedTaxOption;
        final result = depositPlan.calculateTaxOnEarnings(earnings);
        if (!selectedTaxOption.isNotionallyTaxed) {
          continue; // Skip non-notionally taxed options
        }

        double expectedTax = 0;
        double taxableEarnings = earnings;

        if (selectedTaxOption.useTaxExemptionCard) {
          taxableEarnings = earnings - TaxOption.taxExemptionCard;
        }

        if (taxableEarnings <= 0) {
          expectedTax = 0; // No tax if taxable earnings are below or equal to 0
          expect(result, expectedTax);
          continue;
        }

        if (selectedTaxOption.ratePercentage < TaxOption.lowerTaxRate || !selectedTaxOption.useTaxProgressionLimit) {
          expectedTax < 0 ? 0 : expectedTax = taxableEarnings * selectedTaxOption.ratePercentage / 100;
          expect(result, expectedTax);
          continue;
        }
        
        if (taxableEarnings <= TaxOption.taxProgressionLimit) {
          expectedTax < 0 ? 0 : expectedTax = taxableEarnings * TaxOption.lowerTaxRate / 100; // Apply lower tax rate for threshold
          expect(result, expectedTax);
          continue;
        } else {
          expectedTax < 0 ? 0 : expectedTax = (TaxOption.taxProgressionLimit * TaxOption.lowerTaxRate / 100) + ((taxableEarnings - TaxOption.taxProgressionLimit) * selectedTaxOption.ratePercentage / 100);
          expect(result, expectedTax);
          continue;
        }
      }
    });


    test('Earnings above threshold with tax exemption should return correct tax for applicable options', () {
      const earnings = 1050000.0; // Well above threshold
      for (DepositPlan depositPlan in depositPlans) {
        final selectedTaxOption = depositPlan.selectedTaxOption;
        final result = depositPlan.calculateTaxOnEarnings(earnings);
        if (!selectedTaxOption.isNotionallyTaxed) {
          continue; // Skip non-notionally taxed options
        }

        double expectedTax = 0;
        double taxableEarnings = earnings;

        if (selectedTaxOption.useTaxExemptionCard) {
          taxableEarnings = earnings - TaxOption.taxExemptionCard;
        }

        if (taxableEarnings <= 0) {
          expectedTax = 0; // No tax if taxable earnings are below or equal to 0
          expect(result, expectedTax);
          continue;
        }

        if (selectedTaxOption.ratePercentage < TaxOption.lowerTaxRate || !selectedTaxOption.useTaxProgressionLimit) {
          expectedTax < 0 ? 0 : expectedTax = taxableEarnings * selectedTaxOption.ratePercentage / 100;
          expect(result, expectedTax);
          continue;
        }
        
        if (taxableEarnings <= TaxOption.taxProgressionLimit) {
          expectedTax < 0 ? 0 : expectedTax = taxableEarnings * TaxOption.lowerTaxRate / 100; // Apply lower tax rate for threshold
          expect(result, expectedTax);
          continue;
        } else {
          expectedTax < 0 ? 0 : expectedTax = (TaxOption.taxProgressionLimit * TaxOption.lowerTaxRate / 100) + ((taxableEarnings - TaxOption.taxProgressionLimit) * selectedTaxOption.ratePercentage / 100);
          expect(result, expectedTax);
          continue;
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
      const earnings = TaxOption.taxExemptionCard - 1000; // Slightly below threshold for exemption
      for (DepositPlan depositPlan in depositPlans) {
        final selectedTaxOption = depositPlan.selectedTaxOption;
        final result = depositPlan.calculateTaxOnEarnings(earnings);
        if (!selectedTaxOption.isNotionallyTaxed) {
          continue; // Skip non-notionally taxed options
        }

        double expectedTax = 0;
        double taxableEarnings = earnings;

        if (selectedTaxOption.useTaxExemptionCard) {
          taxableEarnings = earnings - TaxOption.taxExemptionCard;
        }

        if (taxableEarnings <= 0) {
          expectedTax = 0; // No tax if taxable earnings are below or equal to 0
          expect(result, expectedTax);
          continue;
        }

        if (selectedTaxOption.ratePercentage < TaxOption.lowerTaxRate || !selectedTaxOption.useTaxProgressionLimit) {
          expectedTax < 0 ? 0 : expectedTax = taxableEarnings * selectedTaxOption.ratePercentage / 100;
          expect(result, expectedTax);
          continue;
        }
        
        if (taxableEarnings <= TaxOption.taxProgressionLimit) {
          expectedTax < 0 ? 0 : expectedTax = taxableEarnings * TaxOption.lowerTaxRate / 100; // Apply lower tax rate for threshold
          expect(result, expectedTax);
          continue;
        } else {
          expectedTax < 0 ? 0 : expectedTax = (TaxOption.taxProgressionLimit * TaxOption.lowerTaxRate / 100) + ((taxableEarnings - TaxOption.taxProgressionLimit) * selectedTaxOption.ratePercentage / 100);
          expect(result, expectedTax);
          continue;
        }
      }
    });
  });
  group('Compound Interest Tests with Capital Gains Tax (no tax in deposit plan)', () {
    test('No investment should return 0 interest', () {
      final depositPlan = DepositPlan(
        principal: 0, // No principal
        interestRate: 7.0,
        duration: 1,
        additionalContribution: 0, // No contributions
        contributionFrequency: 'Monthly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: false, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );
      final result = depositPlan.calculateInterest(12); // 12 periods (monthly)
      expect(result, 0.0);
    });

    test('No interest should return 0 interest', () {
      final depositPlan = DepositPlan(
        principal: 10000.0,
        interestRate: 0.0, // No interest
        duration: 1,
        additionalContribution: 10000.0,
        contributionFrequency: 'Monthly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: false, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );
      final result = depositPlan.calculateInterest(12); // 12 periods (monthly)
      expect(result, 0.0);
    });

    test('Compound interest with no principal should return the correct interest', () {
      final depositPlan = DepositPlan(
        principal: 0,
        interestRate: 7.0, 
        duration: 1,
        additionalContribution: 10000.0, // No contributions
        contributionFrequency: 'Monthly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: false, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );
      const contributionPeriods = 12;
      final result = depositPlan.calculateInterest(contributionPeriods); // 12 periods (monthly)
      double expectedInterest = 0;

      // Now calculate expected compounding for each contribution
      for (int period = 1; period <= contributionPeriods; period++) {
        // Add the contribution
        int periodsLeft = contributionPeriods - period;
        
        // Only compound the contribution for the periods left
        expectedInterest += depositPlan.additionalContribution * (depositPlan.interestRate / 100) * periodsLeft / contributionPeriods;
      }

      expect(result, expectedInterest);
    });

    test('Compound interest with no contributions should return the correct interest', () {
      final depositPlan = DepositPlan(
        principal: 10000.0,
        interestRate: 7.0, 
        duration: 1,
        additionalContribution: 0.0, // No contributions
        contributionFrequency: 'Monthly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: false, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );
      final result = depositPlan.calculateInterest(12); // 12 periods
      final expectedInterest = depositPlan.principal * 0.07; // Interest on principal only
      expect(result, expectedInterest);
    });


    test('Yearly contribution should return the correct interest', () {
      final depositPlan = DepositPlan(
        principal: 10000.0,
        interestRate: 7.0,
        duration: 1,
        additionalContribution: 10000.0,
        contributionFrequency: 'Yearly', // Yearly contributions
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: false, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );
      
      const contributionPeriods = 1;
      final result = depositPlan.calculateInterest(contributionPeriods); // 1 period (yearly)

      // Initialize expected compounding for the principal
      double expectedInterest = 0;
      expectedInterest += depositPlan.principal * (depositPlan.interestRate / 100);
      expect(result, expectedInterest);
    });

    test('Monthly contribution should return correct compound interest', () {
      final depositPlan = DepositPlan(
        principal: 10000.0,
        interestRate: 7.0,
        duration: 1,
        additionalContribution: 10000.0,
        contributionFrequency: 'Monthly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: false, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );    
      const contributionPeriods = 12;
      final result = depositPlan.calculateInterest(contributionPeriods); // 12 periods (monthly)

      // Initialize expected compounding for the principal
      double expectedInterest = depositPlan.principal * (depositPlan.interestRate / 100);

      // Now calculate expected compounding for each contribution
      for (int period = 1; period <= contributionPeriods; period++) {
        // Add the contribution
        int periodsLeft = contributionPeriods - period;
        
        // Only compound the contribution for the periods left
        expectedInterest += depositPlan.additionalContribution * (depositPlan.interestRate / 100) * periodsLeft / contributionPeriods;
      }

      expect(result, expectedInterest);
    });

    test('Full duration of Yearly contribution should return correct compound interest', () {
      final depositPlan = DepositPlan(
        principal: 10000.0,
        interestRate: 7.0,
        duration: 25,
        additionalContribution: 10000.0,
        contributionFrequency: 'Yearly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: false, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );    
      depositPlan.calculateYearlyValues(); // 1 period (Yearly)
      final contributionsResult = depositPlan.totalInterestFromContributions;
      final principalResult = depositPlan.totalInterestFromPrincipal;
      final result = depositPlan.totalInterestFromContributions + depositPlan.totalInterestFromPrincipal;
      double expectedInterest = 0;
      double expectedConbtributionsInterest = 0;
      double expectedPrincipalInterest = 0;
      double additionalContribution = 0;

      for (int year = 1; year <= depositPlan.duration; year++) {
        expectedPrincipalInterest += (depositPlan.principal + expectedPrincipalInterest) * (depositPlan.interestRate / 100);
        expectedConbtributionsInterest += expectedConbtributionsInterest * (depositPlan.interestRate / 100);
        expectedConbtributionsInterest += additionalContribution * (depositPlan.interestRate / 100);
        additionalContribution += depositPlan.additionalContribution;
      }

      expectedInterest =  expectedPrincipalInterest + expectedConbtributionsInterest;
      
      expect(principalResult.toStringAsFixed(5), expectedPrincipalInterest.toStringAsFixed(5));
      expect(contributionsResult.toStringAsFixed(5), expectedConbtributionsInterest.toStringAsFixed(5));
      expect(result.toStringAsFixed(5), expectedInterest.toStringAsFixed(5));
    });

    test('Full duration of Monthly contribution should return correct compound interest', () {
      final depositPlan = DepositPlan(
        principal: 10000.0,
        interestRate: 7.0,
        duration: 25,
        additionalContribution: 10000.0,
        contributionFrequency: 'Monthly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: false, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );    
      const contributionPeriods = 12;
      depositPlan.calculateYearlyValues(); // 12 periods (Monthly)
      final contributionsResult = depositPlan.totalInterestFromContributions;
      final principalResult = depositPlan.totalInterestFromPrincipal;
      final result = depositPlan.totalInterestFromContributions + depositPlan.totalInterestFromPrincipal;
      double expectedInterest = 0;
      double expectedConbtributionsInterest = 0;
      double expectedPrincipalInterest = 0;
      double additionalContribution = 0;

      for (int year = 1; year <= depositPlan.duration; year++) {
        expectedPrincipalInterest += (depositPlan.principal + expectedPrincipalInterest) * (depositPlan.interestRate / 100);
        expectedConbtributionsInterest += expectedConbtributionsInterest * (depositPlan.interestRate / 100);
        expectedConbtributionsInterest += additionalContribution * (depositPlan.interestRate / 100);
        // Now calculate expected compounding for each contribution
        for (int period = 1; period <= contributionPeriods; period++) {
          // Add the contribution
          int periodsLeft = contributionPeriods - period;
          
          // Only compound the contribution for the periods left
          expectedConbtributionsInterest += depositPlan.additionalContribution * (depositPlan.interestRate / 100) * periodsLeft / contributionPeriods;
          additionalContribution += depositPlan.additionalContribution;
        }
      }

      expectedInterest =  expectedPrincipalInterest + expectedConbtributionsInterest;
      
      expect(principalResult.toStringAsFixed(5), expectedPrincipalInterest.toStringAsFixed(5));
      expect(contributionsResult.toStringAsFixed(5), expectedConbtributionsInterest.toStringAsFixed(5));
      expect(result.toStringAsFixed(5), expectedInterest.toStringAsFixed(5));    
    });

  });
  group('Compound Interest Tests with Notional Gains Tax (tax in deposit plan)', () {
  test('No investment should return 0 interest', () {
      final depositPlan = DepositPlan(
        principal: 0, // No principal
        interestRate: 7.0,
        duration: 1,
        additionalContribution: 0, // No contributions
        contributionFrequency: 'Monthly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: true, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );
      final result = depositPlan.calculateInterest(12); // 12 periods (monthly)
      expect(result, 0.0);
    });

    test('No interest should return 0 interest', () {
      final depositPlan = DepositPlan(
        principal: 10000.0,
        interestRate: 0.0, // No interest
        duration: 1,
        additionalContribution: 10000.0,
        contributionFrequency: 'Monthly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: true, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );
      final result = depositPlan.calculateInterest(12); // 12 periods (monthly)
      expect(result, 0.0);
    });

    test('Compound interest with no principal should return the correct interest', () {
      final depositPlan = DepositPlan(
        principal: 0,
        interestRate: 7.0, 
        duration: 1,
        additionalContribution: 10000.0, // No contributions
        contributionFrequency: 'Monthly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: true, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );
      const contributionPeriods = 12;
      final result = depositPlan.calculateInterest(contributionPeriods); // 12 periods (monthly)
      double expectedInterest = 0;

      // Now calculate expected compounding for each contribution
      for (int period = 1; period <= contributionPeriods; period++) {
        // Add the contribution
        int periodsLeft = contributionPeriods - period;
        
        // Only compound the contribution for the periods left
        expectedInterest += depositPlan.additionalContribution * (depositPlan.interestRate / 100) * periodsLeft / contributionPeriods;
      }

      expect(result, expectedInterest);
    });

    test('Compound interest with no contributions should return the correct interest', () {
      final depositPlan = DepositPlan(
        principal: 10000.0,
        interestRate: 7.0, 
        duration: 1,
        additionalContribution: 0.0, // No contributions
        contributionFrequency: 'Monthly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: true, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );
      final result = depositPlan.calculateInterest(12); // 12 periods
      final expectedInterest = depositPlan.principal * 0.07; // Interest on principal only
      expect(result, expectedInterest);
    });


    test('Yearly contribution should return the correct interest', () {
      final depositPlan = DepositPlan(
        principal: 10000.0,
        interestRate: 7.0,
        duration: 1,
        additionalContribution: 10000.0,
        contributionFrequency: 'Yearly', // Yearly contributions
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: true, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );
      
      const contributionPeriods = 1;
      final result = depositPlan.calculateInterest(contributionPeriods); // 1 period (yearly)

      // Initialize expected compounding for the principal
      double expectedInterest = 0;
      expectedInterest += depositPlan.principal * (depositPlan.interestRate / 100);
      expect(result, expectedInterest);
    });

    test('Monthly contribution should return correct compound interest', () {
      final depositPlan = DepositPlan(
        principal: 10000.0,
        interestRate: 7.0,
        duration: 1,
        additionalContribution: 10000.0,
        contributionFrequency: 'Monthly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: true, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );    
      const contributionPeriods = 12;
      final result = depositPlan.calculateInterest(contributionPeriods); // 12 periods (monthly)

      // Initialize expected compounding for the principal
      double expectedInterest = depositPlan.principal * (depositPlan.interestRate / 100);

      // Now calculate expected compounding for each contribution
      for (int period = 1; period <= contributionPeriods; period++) {
        // Add the contribution
        int periodsLeft = contributionPeriods - period;
        
        // Only compound the contribution for the periods left
        expectedInterest += depositPlan.additionalContribution * (depositPlan.interestRate / 100) * periodsLeft / contributionPeriods;
      }

      expect(result, expectedInterest);
    });

    test('Compound interest on principal should return correct amount', () {
      final depositPlan = DepositPlan(
        principal: 10000.0,
        interestRate: 7.0,
        duration: 25,
        additionalContribution: 10000.0,
        contributionFrequency: 'Yearly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: true, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );
      
      depositPlan.calculateYearlyValues(); // Perform yearly calculations
      final principalResult = depositPlan.totalInterestFromPrincipal;
      double previousEarnings = 0;
      
      // Initialize expected principal interest
      double expectedPrincipalInterest = 0;

      for (int year = 1; year <= depositPlan.duration; year++) {
        // Step 1: Compound the interest on principal
        expectedPrincipalInterest += (depositPlan.principal + expectedPrincipalInterest) * (depositPlan.interestRate / 100);

        // Step 2: Apply tax on principal interest if notionally taxed
        double taxableEarnings = expectedPrincipalInterest - previousEarnings;
        double tax = taxableEarnings * depositPlan.selectedTaxOption.ratePercentage / 100;
        expectedPrincipalInterest -= tax;
        previousEarnings = expectedPrincipalInterest;
      }
      // Compare expected vs. actual principal interest
      expect(principalResult.toStringAsFixed(5), expectedPrincipalInterest.toStringAsFixed(5));
    });

    test('Compound interest on yearly contributions should return correct amount', () {
      final depositPlan = DepositPlan(
        principal: 10000.0,
        interestRate: 7.0,
        duration: 25,
        additionalContribution: 10000.0,
        contributionFrequency: 'Yearly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: true, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );

      depositPlan.calculateYearlyValues(); // Perform yearly calculations
      final contributionsResult = depositPlan.totalInterestFromContributions;

      // Initialize expected contributions interest
      double expectedContributionsInterest = 0;
      double additionalContribution = 0;
      double contributions = 0;
      double previousContributionInterest = 0;

      for (int year = 1; year <= depositPlan.duration; year++) {
        // Step 1: Add this year's contribution and compound interest on contributions
        double contributionsInterest = (contributions + previousContributionInterest) * (depositPlan.interestRate / 100);
        expectedContributionsInterest += contributionsInterest;
        additionalContribution = depositPlan.additionalContribution;
        contributions += additionalContribution;
        // Step 2: Apply tax on contributions interest if notionally taxed
        double taxableEarnings = contributionsInterest;
        double tax = taxableEarnings * depositPlan.selectedTaxOption.ratePercentage / 100;
        expectedContributionsInterest -= tax;
        previousContributionInterest = expectedContributionsInterest;
      }
      // Compare expected vs. actual contributions interest
      expect(contributionsResult.toStringAsFixed(5), expectedContributionsInterest.toStringAsFixed(5));
    });

  test('Total interest (principal + contributions) should return correct amount', () {
    final depositPlan = DepositPlan(
      principal: 10000.0,
      interestRate: 7.0,
      duration: 25,
      additionalContribution: 10000.0,
      contributionFrequency: 'Yearly',
      selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: true, useTaxExemptionCard: false, useTaxProgressionLimit: false),
    );

    depositPlan.calculateYearlyValues(); // Perform yearly calculations
    final result = depositPlan.totalInterestFromContributions + depositPlan.totalInterestFromPrincipal;
    double principalInterest = 17045.53264;
    double contributionsInterest = 169840.70551;

    // Compare expected vs. actual total interest
    expect(result.toStringAsFixed(5), (principalInterest + contributionsInterest).toStringAsFixed(5));
  });

    test('Full duration of Monthly contribution should return correct compound interest', () {
      final depositPlan = DepositPlan(
        principal: 10000.0,
        interestRate: 7.0,
        duration: 25,
        additionalContribution: 10000.0,
        contributionFrequency: 'Monthly',
        selectedTaxOption: TaxOption(42.0, 'Custom', isNotionallyTaxed: true, useTaxExemptionCard: false, useTaxProgressionLimit: false),
      );    
      depositPlan.calculateYearlyValues(); // Perform yearly calculations
      final contributionsResult = depositPlan.totalInterestFromContributions;
      const int contributionPeriods = 12;
      // Initialize expected contributions interest
      double expectedContributionsInterest = 0;
      double additionalContribution = 0;
      double contributions = 0;
      double previousContributionInterest = 0;

      for (int year = 1; year <= depositPlan.duration; year++) {
        // Step 1: Add this year's contribution and compound interest on contributions
        double contributionsInterest = (contributions + previousContributionInterest) * (depositPlan.interestRate / 100);
        additionalContribution = depositPlan.additionalContribution;

        // Now handle contributions and their compounding
        for (int period = 1; period <= contributionPeriods; period++) {
          contributions += additionalContribution; // Add contributions

          int periodsLeft = contributionPeriods - period;
          contributionsInterest += additionalContribution * (depositPlan.interestRate / 100) * periodsLeft / contributionPeriods; // Compound contributions for remaining periods
        }
        
        expectedContributionsInterest += contributionsInterest;

        // Step 2: Apply tax on contributions interest if notionally taxed
        double taxableEarnings = contributionsInterest;
        double tax = taxableEarnings * depositPlan.selectedTaxOption.ratePercentage / 100;
        expectedContributionsInterest -= tax;
        previousContributionInterest = expectedContributionsInterest;
      }
      // Compare expected vs. actual contributions interest
      expect(contributionsResult.toStringAsFixed(5), expectedContributionsInterest.toStringAsFixed(5));
    });
  });
}