// import 'package:daily_mate/common/widgets/app_button/t_app_button.dart';
// import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
// import 'package:daily_mate/common/widgets/text_fields/text_field.dart';
// import 'package:daily_mate/features/controllers/settings_controller/water_reminder_controller.dart';
// import 'package:daily_mate/utils/constants/sizes.dart';
// import 'package:daily_mate/utils/helpers/helper_functions.dart';
// import 'package:flutter/material.dart';
// import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
// import 'package:daily_mate/utils/constants/colors.dart';
// import 'package:get/get.dart';
// import 'package:iconsax/iconsax.dart';

// class WaterReminderListView extends StatelessWidget {
//   WaterReminderListView({super.key});

//   final WaterReminderController controller = Get.put(
//     WaterReminderController(),
//     tag: "WaterReminderController",
//   );

//   @override
//   Widget build(BuildContext context) {
//     final textStyle = Theme.of(context).textTheme;
//     final isDark = THelperFunctions.isDarkMode(context);

//     return Scaffold(
//       appBar: TCommonAppBar(
//         showBackArrow: true,
//         appBarWidget: Text(
//           "Active Water Reminders",
//           style: textStyle.titleSmall?.copyWith(color: TColors.white),
//         ),
//       ),
//       body: Column(
//                   children: [
//                     if(true) // condition aayegi today's reminder ya tommorrow reminder if user sets reminder for today and tomorrow then display sepaarte for toadays and for tomorrow and for custom date like 8 sep 2025
//                     Text("Today's Reminder",style: textStyle.titleSmall,),
//                     TRoundedContainer(
//                       backgroundColor: isDark?TColors.darkerGrey:TColors.light,
//                       child: Row(
//                         children: [
//                           Icon(Iconsax.alarm),
//                           SizedBox(width: TSizes.spaceBtwItems,),
//                           Column(
//                             children: [
//                               Text("Reminder : 1232879"),
//                               SizedBox(height: TSizes.spaceBtwItems/3,),
//                               Row(
//                                 children: [
//                                   Text("Target :2000 ml"),
//                                   SizedBox(width: TSizes.spaceBtwItems,),
//                                   Text("Left :1000 ml"),
//                                 ],
//                               )
//                             ],
//                           )
//                         ],
//                       ),
//                     )
//                   ]
                      
//                 )

//     );
//   }
// }
