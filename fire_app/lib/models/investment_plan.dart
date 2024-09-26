class InvestmentPlan {
  final String name;
  final double principal;
  final double interestRate;
  final int duration;
  final String contributionFrequency;
  final double additionalAmount;
  final int breakPeriod;
  final int withdrawalPeriod;
  final double taxRate;

  InvestmentPlan(
    this.name,
    this.breakPeriod,
    this.withdrawalPeriod,
    this.taxRate,{
    required this.principal, 
    required this.additionalAmount, 
    required this.interestRate,
    required this.duration,
    required this.contributionFrequency,
  });
}