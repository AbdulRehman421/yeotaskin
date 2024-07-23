import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/view/dashboard/widgets/table.dart';
import '../../../APIs/urls.dart';
import '../../../utilities/app_colors.dart';

class IndividualSalesScreen extends StatefulWidget {
  const IndividualSalesScreen({super.key});

  @override
  State<IndividualSalesScreen> createState() => _IndividualSalesScreenState();
}

class _IndividualSalesScreenState extends State<IndividualSalesScreen> {
  bool salesLoading = false;
  List agentSalesList = [];

  void setLoading(bool status) {
    setState(() {
      salesLoading = status;
    });
  }

  Future<void> getAgentSales() async {
    setLoading(true);
    try {
      final response =
          await http.get(Uri.parse("${URLs.baseURL}${URLs.agentSaleURL}"));
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        debugPrint("AgentSale: ${jsonDecode(response.body)}");
        if (jsonDecode(response.body)['data'] != null) {
          agentSalesList = jsonDecode(response.body)['data'];
        }
        for (int i = 0; i < agentSalesList.length - 1; i++) {
          for (int j = i + 1; j < agentSalesList.length; j++) {
            if (int.parse(agentSalesList[i]['total_sales'].toString()) <
                int.parse(agentSalesList[j]['total_sales'].toString())){
              Map<String, dynamic> temp = agentSalesList[i];
              agentSalesList[i] = agentSalesList[j];
              agentSalesList[j] = temp;
            }
          }
        }

        setState(() {});
      } else {
        debugPrint("getAgentSales(): else Error");
      }
    } catch (e) {
      debugPrint("getAgentSales(): ${e.toString()}");
    }
    setLoading(false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAgentSales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: Text(
            "Individual Sales",
            style: TextStyle(
              fontFamily: AppFonts.palatino,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        body: !salesLoading
            ? agentSalesList.isNotEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
                    child: TableWidget(
                      headerText: const ['', '', 'Name', 'Sales (RM)'],
                      columnData: agentSalesList,
                    ),
                  )
                : const Center(
                    child: Text('No data'),
                  )
            : Center(
                child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              )));
  }
}
