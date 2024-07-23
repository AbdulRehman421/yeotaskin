class HomeModel{
  double? rebateWallet;
  double? incomeWallet;
  double? individualSales;
  double? teamSales;
  String? moq;

  HomeModel({
    required this.rebateWallet,
    required this.incomeWallet,
    required this.individualSales,
    required this.teamSales,
    required this.moq,
});

  HomeModel.fromJson(Map<String, dynamic> json){
    rebateWallet = double.parse((json['rebate wallet'] ?? 0).toString()) ;
    incomeWallet = double.parse((json['income_wallet'] ?? 0).toString());
    individualSales = double.parse((json['individual sales'] ?? 0).toString());
    teamSales = double.parse((json['total_amount'] ?? 0).toString());
    moq = json['moq'] ?? '';
  }
}