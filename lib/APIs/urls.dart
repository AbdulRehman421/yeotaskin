class URLs {
  // base url
  static const String baseURL = "https://admin.yeotaskin.com/";
  //static const String baseURL = "https://acm.bevious.com/";

  //auth url
  static const String loginURL = "api/login";
  static const String registerURL = "api/register";

  //forgot password
  static const String forgotURL = "api/forget_password";
  static const String otpURL = "api/verify_otp";
  static const String newPasswordURL = "api/update_password";

  //delete account
  static const String deleteAccountURL = "api/delete-user";

  //get products
  static const String getProductsURL = "api/all-products";
  static const String getProductPriceURL = "api/getProductLevelPrice";

  //get stock
  static const String getAvailableStockURL = "api/agent-available-stocks";

  //get home
  static const String getHomeURL = "api/home_page";

  // Profile
  static const String getUserProfileURL = "api/get-user-profile";
  static const String updateUserProfileURL = "api/update-user-profile";

  //get agent and team sales
  static const String agentSaleURL = "api/agent_sales";
  static const String teamSaleBatchUrl = "api/team_sales_batch";
  static const String teamSalesURL = "api/team_sales";
  static const String referralURL = "api/downline";

  //submit order
  static const String submitOrderURL = "api/agent-stock-purchase";

  //get order history
  static const String getOrderHistoryURL = "api/agent-order";

  //get customer order
  static const String getCustomerOrderURL = "api/all-orders";

  //acount details
  static const String storeBankAccountDetailsURL =
      "api/user-store-bank-details";
  static const String getBankAccountDetailsURL = "api/user-bank-details";

  //get income logs
  static const String getIncomeLogs = "api/income_logs";

  //get level
  static const String getLevelURL = "api/levelList";

  //get shipping fee
  static const String getShippingFeeURL = "api/shipping-fee/6";

  //get shipping fee
  static const String getTopUpWithdrawURL = "api/withdraw-request";

  //get knowledge base
  static const String getKnowledgeBaseURL = "api/knowledge-base";

  // get to-do task
  static const String getTaskURL = "api/get-task";

  // get to-do task
  static const String getPrizesURL = "api/getprizelist";

  // post to-do task
  static const String postTaskURL = "api/store-task";

  //view invoice
  static const String viewInvoiceURL = "api/admin/order/download_invoice";
}
