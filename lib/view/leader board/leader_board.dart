import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yeotaskin/APIs/urls.dart';
import 'package:yeotaskin/services/user_profile_manager.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/utilities/utilities.dart';

class LeaderBoardScreen extends StatefulWidget {
  const LeaderBoardScreen({super.key});

  @override
  _LeaderBoardScreenState createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen>
    with AutomaticKeepAliveClientMixin {
  bool salesLoading = false;
  int currentTab = 0;
  List agentSalesList = [];
  List teamSalesList = [];
  List referral = [];
  List rawreferral = [];
  List count = [];

  void setLoading(bool status) {
    setState(() {
      salesLoading = status;
    });
  }

  // List bothSalesList = [];
  Future<void> getAgentSales() async {
    setLoading(true); // Assuming setLoading is a function to set loading state

    try {
      final response =
          await http.get(Uri.parse("${URLs.baseURL}${URLs.agentSaleURL}"));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true) {
          debugPrint("AgentSale: $responseBody");

          // Check if data is present and convert it to a list if available
          if (responseBody['data'] != null) {
            List<dynamic> agentSalesList = responseBody['data'];

            // Sort agentSalesList based on total_sales if it's valid
            agentSalesList.sort((a, b) {
              // Ensure total_sales are valid integers before comparison
              var totalSalesA = a['total_sales'];
              var totalSalesB = b['total_sales'];

              if (totalSalesA != null && totalSalesB != null) {
                // Attempt to parse and compare as integers
                try {
                  return int.parse(totalSalesB.toString()) -
                      int.parse(totalSalesA.toString());
                } catch (e) {
                  debugPrint("Error parsing total_sales as integer: $e");
                  return 0; // Handle parse error gracefully, maybe log and continue
                }
              } else {
                // Handle cases where total_sales is null or missing
                return 0; // Default behavior or handle differently as needed
              }
            });

            // Assuming agentSalesList is a class variable
            this.agentSalesList = agentSalesList;
          }

          // Proceed to fetch team sales data
          getTeamSales();
        } else {
          debugPrint("getAgentSales(): Error - Success is not true");
          // Handle error case where success is not true
        }
      } else {
        debugPrint(
            "getAgentSales(): Error - Status code ${response.statusCode}");
        // Handle error case where response status code is not 200
      }
    } catch (e) {
      debugPrint("getAgentSales(): Exception - ${e.toString()}");
      // Handle other exceptions such as network errors
    } finally {
      setLoading(false); // Reset loading state regardless of success or failure
    }
  }

  Future<void> getTeamSales() async {
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
                int.parse(teamSalesList[j]['total_sales'].toString())) {
              Map<String, dynamic> temp = teamSalesList[i];
              teamSalesList[i] = teamSalesList[j];
              teamSalesList[j] = temp;
            }
          }
        }
        await getReffreal();
      } else {
        debugPrint("getTeamSales: else Error");
      }
    } catch (e) {
      debugPrint("getTeamSales: ${e.toString()}");
    }
  }

  Future<void> getReffreal() async {
    try {
      String? token = await UserProfileManager().getUserToken();
      var response = await http.get(
          Uri.parse("${URLs.baseURL}${URLs.referralURL}"),
          headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body)['data'];
        for (var i = 0; i < data.length; i++) {
          rawreferral.add(data[i]);

          if (data[i]['upline'].toString() != "Select" &&
              data[i]['upline'].toString() != "null") {
            referral.add(data[i]);
          }
        }

        if (kDebugMode) {
          print(referral);
        }

        for (int i = 0; i < referral.length - 1; i++) {
          for (int j = i + 1; j < referral.length; j++) {
            if (referral[i]['upline'].toString() != "Select" &&
                referral[i]['upline'].toString() != "null") {
              if (int.parse(referral[i]['upline'].toString()) <
                  int.parse(referral[j]['upline'].toString())) {
                Map<String, dynamic> temp = referral[i];
                referral[i] = referral[j];
                referral[j] = temp;
              }
            }
          }
        }

        count.clear();
        for (var i = 0; i < referral.length; i++) {
          var len = count
              .where((element) =>
                  element['name'] == referral[i]['upline'].toString())
              .length;

          if (len != 0) {
          } else {
            var id = rawreferral
                .where((element) =>
                    element['id'].toString() ==
                    referral[i]['upline'].toString())
                .toList();

            count.add({
              "name": referral[i]['upline'],
              "idname": id.isEmpty ? null : id[0]['name'],
              "value": referral
                  .where((element) =>
                      element['upline'] == referral[i]['upline'].toString())
                  .length
            });
          }
        }
        if (kDebugMode) {
          print(count);
        }
        count.removeWhere((element) =>
            element['idname'].toString().toLowerCase() ==
            "acm admin".toString());

        for (int i = 0; i < count.length - 1; i++) {
          for (int j = i + 1; j < count.length; j++) {
            if (count[i]['value'].toString() != "Select" &&
                count[i]['value'].toString() != "null") {
              if (int.parse(count[i]['value'].toString()) <
                  int.parse(count[j]['value'].toString())) {
                Map<String, dynamic> temp = count[i];
                count[i] = count[j];
                count[j] = temp;
              }
            }
          }
        }
        setState(() {});
      } else {
        debugPrint("getAgentSales(): else Error");
      }
      // print(response.statusCode);
      // print(response.body);
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
    super.build(context);
    return Scaffold(
      body: !salesLoading
          ? DefaultTabController(
              length: 3,
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      pinned: false,
                      expandedHeight: 300,
                      title: const Center(
                        child: Text(
                          "Leaderboard",
                          style: TextStyle(
                            fontFamily: AppFonts.palatino,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(300),
                          child: currentTab == 0
                              ? agentSalesList.isNotEmpty
                                  ? topWidget(agentSalesList)
                                  : const Center(
                                      child: Text(
                                        "Nothing found!",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: AppFonts.palatino,
                                          fontSize: 18,
                                        ),
                                      ),
                                    )
                              : currentTab == 1
                                  ? teamSalesList.isNotEmpty
                                      ? topWidget(teamSalesList)
                                      : const Center(
                                          child: Text(
                                            "Nothing found!",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: AppFonts.palatino,
                                              fontSize: 18,
                                            ),
                                          ),
                                        )
                                  : teamSalesList.isNotEmpty
                                      ? topWidget(count)
                                      : const Center(
                                          child: Text(
                                            "Nothing found!",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: AppFonts.palatino,
                                              fontSize: 18,
                                            ),
                                          ),
                                        )),
                    ),
                    SliverPersistentHeader(
                      delegate: MySliverPersistentHeaderDelegate(
                        TabBar(
                          unselectedLabelColor:
                              AppColors.theme.withOpacity(0.5),
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.person_2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Individual',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: AppFonts.palatino,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Tab(
                              icon: Icon(Icons.group),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Team',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: AppFonts.palatino,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Tab(
                              icon: Icon(Icons.group),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Referral',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: AppFonts.palatino,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onTap: (value) {
                            currentTab = value;
                            setState(() {});
                          },
                        ),
                      ),
                      pinned: false,
                    ),
                  ];
                },
                body: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    LeaderboardList(
                        data: agentSalesList.isNotEmpty ? agentSalesList : []),
                    LeaderboardList(
                        data: teamSalesList.isNotEmpty ? teamSalesList : []),
                    LeaderboardList(data: count.isNotEmpty ? count : []),
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
    );
  }

  Widget topWidget(List<dynamic> salesList) {
    return Column(
      children: [
        ClipPath(
          clipper: CustomClipPath(),
          child: Container(
            padding: EdgeInsets.zero,
            height: 300,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.backgroundColor.withOpacity(0.1),
                  AppColors.backgroundColor.withOpacity(1),
                  Colors.amberAccent,
                ],
              ),
              image: const DecorationImage(
                image: AssetImage(
                  'assets/images/glitter.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 31.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  placementIndicator(
                    height: 200,
                    placement: '2',
                    bgColor: AppColors.twoLevelColor,
                    textColor: const Color.fromARGB(255, 71, 50, 30),
                    name: (salesList.length > 1
                        ? salesList[1]['idname'] != null
                            ? salesList[1]['idname'].toString()
                            : salesList[1]["name"] ?? ""
                        : ''),
                    amount: salesList.length > 1
                        ? salesList[1]["total_sales"].toString() == "null"
                            ? salesList[1]["value"].toString()
                            : salesList[1]["total_sales"].toString()
                        : '',
                  ),
                  placementIndicator(
                    height: 250,
                    placement: '1',
                    bgColor: AppColors.topLevelColor,
                    textColor: AppColors.backgroundColor,
                    name: (salesList.isNotEmpty
                        ? salesList[0]['idname'] != null
                            ? salesList[0]['idname'].toString()
                            : salesList[0]["name"].toString()
                        : '-'),
                    amount: salesList.isNotEmpty
                        ? salesList[0]["total_sales"].toString() == "null"
                            ? salesList[0]["value"].toString()
                            : salesList[0]["total_sales"].toString()
                        : '',
                  ),
                  placementIndicator(
                    height: 160,
                    placement: '3',
                    bgColor: AppColors.threeLevelColor,
                    textColor: const Color.fromARGB(255, 144, 101, 58),
                    name: (salesList.length > 2
                        ? salesList[2]['idname'] != null
                            ? salesList[2]['idname'].toString()
                            : salesList[2]['name'].toString()
                        : "-"),
                    amount: salesList.length > 2
                        ? salesList[2]["total_sales"].toString() == "null"
                            ? salesList[2]["value"].toString()
                            : salesList[2]["total_sales"].toString()
                        : "",
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  MySliverPersistentHeaderDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(child: _tabBar);
  }

  @override
  bool shouldRebuild(MySliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path_0 = Path();
    path_0.moveTo(0, size.height * 0.0020000);
    path_0.lineTo(size.width, size.height * 0.0040000);
    path_0.lineTo(size.width * 0.9986667, size.height * 0.8672000);
    path_0.quadraticBezierTo(size.width * 0.7184167, size.height * 0.9963000,
        size.width * 0.5010000, size.height * 1.0004000);
    path_0.quadraticBezierTo(size.width * 0.2737500, size.height * 1.0069000,
        size.width * 0.0013333, size.height * 0.8616000);
    path_0.lineTo(0, size.height * 0.0020000);
    path_0.close();
    return path_0;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class LeaderboardList extends StatelessWidget {
  final List data;

  const LeaderboardList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    int offset = 3;
    return data.isNotEmpty
        ? ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: data.length - offset,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.background,
                      AppColors.background,
                      AppColors.accent,
                    ],
                    stops: [0.1, 0.2, 0.2],
                  ),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(width: 1, color: Colors.white),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      alignment: Alignment.centerLeft,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(100),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
                      child: Text(
                        (4 + index).toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: AppFonts.optima,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(100),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(8, 12, 30, 12),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? MediaQuery.of(context).size.width * 0.45
                              : MediaQuery.of(context).size.width * 0.6,
                          minWidth: MediaQuery.of(context).size.width * 0.15,
                        ),
                        child: Text(
                          data[index + offset]['idname']
                                  ?.toString()
                                  .toTitleCase() ??
                              data[index + offset]['name']
                                  ?.toString()
                                  .toTitleCase() ??
                              ""
                                  '-',
                          softWrap: true,
                          maxLines: 3,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: AppFonts.optima,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.fromLTRB(8, 10, 24, 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              data[index + offset]['total_sales'].toString() ==
                                      "null"
                                  ? data[index + offset]['value'].toString()
                                  : data[index + offset]['total_sales']
                                      .toString(),
                              style: const TextStyle(
                                fontFamily: AppFonts.arial,
                                fontWeight: FontWeight.bold,
                                color: AppColors.backgroundColor,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            data[index + offset]['total_sales'].toString() !=
                                    "null"
                                ? Text(
                                    'RM',
                                    style: TextStyle(
                                      fontFamily: AppFonts.arial,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.backgroundColor
                                          .withOpacity(0.9),
                                      fontSize: 10,
                                    ),
                                  )
                                : const SizedBox()
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        : const Center(
            child: Text('No data'),
          );
  }
}

Widget placementIndicator({
  required double height,
  required String placement,
  required Color bgColor,
  required Color textColor,
  required String name,
  required String amount,
}) {
  return Card(
    elevation: 15,
    margin: EdgeInsets.zero,
    child: Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, placement == '1' ? 5 : 20),
      width: 110,
      height: height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(10),
        ),
        gradient: LinearGradient(
          colors: [
            bgColor.withOpacity(0.45),
            bgColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          width: 2,
          color: AppColors.background,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  placement,
                  style: TextStyle(
                    fontFamily: AppFonts.palatino,
                    color: bgColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          Text(
            name.toTitleCase(),
            style: TextStyle(
              fontFamily: AppFonts.optima,
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
            softWrap: true,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
          Text(
            amount,
            softWrap: true,
            maxLines: 2,
            style: TextStyle(
              fontFamily: AppFonts.arial,
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (placement == '1')
            const Image(
              image: AssetImage(
                "assets/images/trophy.png",
              ),
              height: 40,
            ),
        ],
      ),
    ),
  );
}
