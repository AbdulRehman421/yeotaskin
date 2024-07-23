import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';

class IncomeLogCard extends StatelessWidget {
  final String description;
  final String income;
  final String dateTime;
  const IncomeLogCard({super.key, required this.description, required this.income, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Card(

      surfaceTintColor: AppColors.backgroundColor,
      color: AppColors.primaryColor,
      child: ListTile(
        leading: const Icon(Icons.price_check_outlined,color: AppColors.backgroundColor,size: 30,),
        title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(dateTime.substring(0,10),style: const TextStyle(fontFamily: AppFonts.palatino,fontSize: 18),),
          Text(dateTime.substring(10),style: const TextStyle(fontFamily: AppFonts.palatino,fontSize: 18),),
        ],
      ),
      subtitle: Text(description,style: const TextStyle(fontFamily: AppFonts.palatino),),
        trailing: SizedBox(
          width: 100,
            child: Text("$income RM",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16,fontFamily: AppFonts.palatino,color: AppColors.backgroundColor),),),
      ),

    );
  }
}
