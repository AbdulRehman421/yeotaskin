class PriceUtility {
  static String priceWithSymbol(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }
}