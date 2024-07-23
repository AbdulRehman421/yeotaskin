import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/view/dashboard/widgets/table.dart';
import '../../../APIs/urls.dart';
import '../../../utilities/app_colors.dart';

class TeamSalesScreen extends StatefulWidget {
  const TeamSalesScreen({super.key});

  @override
  State<TeamSalesScreen> createState() => _TeamSalesScreenState();
}

class _TeamSalesScreenState extends State<TeamSalesScreen> {
  List teamSalesList = [];
  bool salesLoading = false;

  void setLoading(bool status) {
    setState(() {
      salesLoading = status;
    });
  }

  Future<void> getTeamSales() async {
    setLoading(true);
    try {
      final response =
          await http.get(Uri.parse("${URLs.baseURL}${URLs.teamSalesURL}"));

      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        if (jsonDecode(response.body)['data'] != null) {
          teamSalesList = jsonDecode(response.body)['data'];
        }
        debugPrint("TeamSale: ${jsonDecode(response.body)}");
        for (int i = 0; i < teamSalesList.length - 1; i++) {
          for (int j = i + 1; j < teamSalesList.length; j++) {
            if (int.parse(teamSalesList[i]['total_sales'].toString()) <
                int.parse(teamSalesList[j]['total_sales'].toString()) ) {
              Map<String, dynamic> temp = teamSalesList[i];
              teamSalesList[i] = teamSalesList[j];
              teamSalesList[j] = temp;
            }
          }
        }
        setState(() {});
      } else {
        debugPrint("getTeamSales: else Error");
      }
    } catch (e) {
      debugPrint("getTeamSales: ${e.toString()}");
    }
    setLoading(false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTeamSales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: const Text(
            "Team Sales",
            style: TextStyle(
              fontFamily: AppFonts.palatino,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        body: !salesLoading
            ? teamSalesList.isNotEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
                    child: TableWidget(
                      headerText: ['', '', 'Name', 'Sales (RM)'],
                      columnData: teamSalesList,
                    ),
                  )
                : const Center(
                    child: Text('No data'),
                  )
            : const Center(
                child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              )));
  }
}
