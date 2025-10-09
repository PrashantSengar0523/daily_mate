import 'package:daily_mate/common/widgets/app_button/t_app_button.dart';
import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/features/controllers/admin_controller.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminView extends StatelessWidget {
  AdminView({super.key});

final AdminController controller = Get.put(AdminController());
  @override
  Widget build(BuildContext context) {
 final textStyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: TCommonAppBar(
        showBackArrow: true,
        appBarWidget: Row(
          children: const [
            Text("Admin View"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: TSizes.md / 1.2),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TRoundedContainer(
              padding: EdgeInsets.all(TSizes.md/1.3),
              backgroundColor: isDark?TColors.darkerGrey:TColors.light,
              child: Row(
                children: [
                  Expanded(child: Text("Upload Festival Single Templates",style: textStyle.bodyMedium,)),
                  SizedBox(width: TSizes.spaceBtwItems,),
                  Obx(()=>
                     TAppButton(
                      onPressed: () async{
                        controller.uploadFestivalTemplate();
                      },
                      isLoading: controller.isLoading.value,
                      height: 36,
                      text: "Upload",
                      
                      ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            TRoundedContainer(
              padding: EdgeInsets.all(TSizes.md/1.3),
              backgroundColor: isDark?TColors.darkerGrey:TColors.light,
              child: Row(
                children: [
                  Expanded(child: Text("Upload Bulk Festival Templates",style: textStyle.bodyMedium,)),
                  SizedBox(width: TSizes.spaceBtwItems,),
                  Obx(()=>
                     TAppButton(
                      isLoading: controller.isLoading.value,
                      height: 36,
                      text: "Upload",
                      
                      ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            TRoundedContainer(
              padding: EdgeInsets.all(TSizes.md/1.3),
              backgroundColor: isDark?TColors.darkerGrey:TColors.light,
              child: Row(
                children: [
                  Expanded(child: Text("Upload Single Background Templates",style: textStyle.bodyMedium,)),
                  SizedBox(width: TSizes.spaceBtwItems,),
                  Obx(()=>
                     TAppButton(
                      isLoading: controller.isLoading.value,
                      height: 36,
                      text: "Upload",
                      onPressed: ()async {
                        controller.uploadBackgroundTemplate();
                      },
                      ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            TRoundedContainer(
              padding: EdgeInsets.all(TSizes.md/1.3),
              backgroundColor: isDark?TColors.darkerGrey:TColors.light,
              child: Row(
                children: [
                  Expanded(child: Text("Upload Bulk Background Templates",style: textStyle.bodyMedium,)),
                  SizedBox(width: TSizes.spaceBtwItems,),
                  Obx(()=>
                     TAppButton(
                      isLoading: controller.isLoading.value,
                      height: 36,
                      text: "Upload",
                      
                      ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
