// ignore_for_file: deprecated_member_use
import 'package:daily_mate/common/widgets/text_fields/t_bottom_sheet_text_field.dart';
import 'package:daily_mate/features/models/track_expense_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:daily_mate/common/widgets/app_button/t_app_button.dart';
import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/common/widgets/containers/rounded_container.dart';
import 'package:daily_mate/common/widgets/text_fields/text_field.dart';
import 'package:daily_mate/common/widgets/view_widgets/t_empty_widget.dart';
import 'package:daily_mate/features/controllers/settings_controller/track_expense_controller.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/image_strings.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/formatters/formatter.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:daily_mate/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class TrackExpenseView extends StatelessWidget {
  TrackExpenseView({super.key});

  final TrackExpenseController controller = Get.put(
    TrackExpenseController(),
    tag: "TrackExpenseController",
  );
  final GlobalKey<FormState> _addExpenseKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    // final isDark = THelperFunctions.isDarkMode(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TCommonAppBar(
          showBackArrow: true,
          appBarWidget: Text(
            TTexts.expenses.tr,
            style: textStyle.titleMedium?.copyWith(
              color: TColors.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        floatingActionButton:
            MediaQuery.of(context).viewInsets.bottom > 0
                ? null // hide FAB when keyboard open
                : FloatingActionButton(
                  backgroundColor: TColors.primary,
                  onPressed: () {
                    showAddEditExpenseDialog(context, textStyle);
                  },
                  child: const Icon(Iconsax.add, color: Colors.white),
                ),
        body: Padding(
          padding: const EdgeInsets.all(TSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Summary Cards Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Obx(
                      () => _SummaryCard(
                        title: "Overall",
                        amount: "₹${controller.totalExpense.value}",
                        color: Colors.deepOrange,
                        icon: Icons.wallet,
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        monthylyExpenseAnalyticsChart(context);
                      },
                      child: _SummaryCard(
                        title: "Analytics",
                        amount: "-",
                        color: Colors.orangeAccent,
                        icon: Iconsax.activity5,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: TSizes.spaceBtwItems),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Obx(
                      () => _SummaryCard(
                        title: TTexts.thisWeek.tr,
                        amount: "₹${controller.thisWeekExpense.value}",
                        color: Colors.green,
                        icon: Iconsax.calendar5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => _SummaryCard(
                        title: TTexts.thisMonth.tr,
                        amount: "₹${controller.thisMonthExpense.value}",
                        color: Colors.orangeAccent,
                        icon: Iconsax.calendar_25,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// 🔹 Expense List Header
              Row(
                children: [
                  Text(
                    TTexts.recentExpense.tr,
                    style: textStyle.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  TRoundedContainer(
                    onTap: () {
                      showResetExpenseDialog(context, textStyle);
                    },
                    showShadow: false,
                    padding: EdgeInsets.all(8),
                    radius: 11,
                    backgroundColor: Colors.cyanAccent.withOpacity(0.15),
                    child: Text(
                      TTexts.reset.tr,
                      style: textStyle.labelLarge?.copyWith(
                        fontSize: TSizes.fontSizeSm,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// 🔹 Expense List
              Flexible(
                child: Obx(() {
                  if (controller.expenses.isEmpty) {
                    return SingleChildScrollView(
                      child: SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                            0.5, // adjust height
                        child: Center(child: TEmptyWidget()),
                      ),
                    );
                  }
                  final data = controller.expenses;
                  return ListView.builder(
                    itemCount: data.length,

                    itemBuilder: (context, index) {
                      final expense = data[index];

                      return ExpenseTile(
                        title: expense.name,
                        amount: expense.amount,
                        date: TFormatter.formatDate(expense.date),
                        onDelete: () {
                          controller.deleteExpense(index);
                        },
                        onEdit:
                            () => showAddEditExpenseDialog(
                              context,
                              textStyle,
                              expense: expense,
                            ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAddEditExpenseDialog(
    BuildContext context,
    TextTheme textStyle, {
    TrackExpenseModel? expense,
    int? index,
  }) {
    // Agar edit mode hai toh controllers me data daalo
    if (expense != null) {
      controller.expenseNameController.text = expense.name;
      controller.expenseAmount.text = expense.amount.toString();
      controller.expenseDate.text = DateFormat(
        'd MMMM, y',
      ).format(expense.date);
    } else {
      controller.expenseNameController.clear();
      controller.expenseAmount.clear();
      controller.expenseDate.clear();
    }

    TDialogs.defaultDialog(
      context: context,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _addExpenseKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      expense == null
                          ? TTexts.addExpense.tr
                          : TTexts.editExpense.tr,
                      style: textStyle.titleSmall,
                    ),
                    const Icon(Iconsax.close_circle5),
                  ],
                ),
                const SizedBox(height: TSizes.defaultSpace),

                TCustomBottomSheetInput(
                  items:
                      controller.expenseCategories
                          .map((cat) => cat["name"] as String)
                          .toList(),
                  hintText: "Select Category",
                  enableSearch: true,
                  controller: controller.expenseNameController,
                  validator:
                      (val) => TValidator.validateEmptyText("Category", val),
                ),

                const SizedBox(height: TSizes.spaceBtwInputFields),

                TTextField(
                  hintText: TTexts.amount.tr,
                  controller: controller.expenseAmount,
                  textInputType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}$'),
                    ),
                  ],
                  validator:
                      (val) =>
                          TValidator.validateEmptyText(TTexts.amount.tr, val),
                ),

                const SizedBox(height: TSizes.spaceBtwInputFields),

                TTextField(
                  hintText: TTexts.date.tr,
                  controller: controller.expenseDate,
                  readOnly: true,
                  validator:
                      (val) =>
                          TValidator.validateEmptyText(TTexts.date.tr, val),
                  suffixIcon: InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final date = await showDatePicker(
                        context: context,
                        initialDate: expense?.date ?? now,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        controller.expenseDate.text = DateFormat(
                          'd MMMM, y',
                        ).format(date);
                      }
                    },
                    child: const Icon(Icons.date_range_rounded),
                  ),
                ),
                const SizedBox(height: TSizes.defaultSpace),

                TAppButton(
                  text: TTexts.save.tr,
                  height: 36,
                  onPressed: () {
                    if (_addExpenseKey.currentState!.validate()) {
                      if (expense == null) {
                        // Add new expense
                        controller.addExpense();
                      } else {
                        // Update existing expense
                        controller.editExpense(index!, expense);
                      }
                      Get.back();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showResetExpenseDialog(BuildContext context, TextTheme textStyle) {
    TDialogs.defaultDialog(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TTexts.recentExpense.tr,
            style: textStyle.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 2),

          Text(
            TTexts.resetExpenseSubtitle.tr,
            style: textStyle.bodyMedium?.copyWith(color: TColors.darkGrey),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TAppOutlinedButton(
                  text: TTexts.cancel.tr,
                  height: 36,
                  textColor: Colors.redAccent,
                  borderColor: Colors.redAccent,
                ),
              ),
              SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: TAppButton(
                  onPressed: () {
                    Get.back();
                    controller.deleteExpenses();
                  },
                  text: TTexts.reset.tr,
                  height: 36,
                  textColor: TColors.textWhite,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

void monthylyExpenseAnalyticsChart(BuildContext context) {
  // Get category wise data for current month
  final categoryData = controller.getCurrentMonthCategoryExpenses();

  TDialogs.defaultDialog(
    context: context,
    child: SizedBox(
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Heading
          Text(
            "Monthly Expense Overview",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          /// 🔹 Legend (Categories with colors)
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: categoryData.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: entry.value["color"] as Color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          /// 🔹 Pie Chart
          Expanded(
            child: PieChart(
              PieChartData(
                sections: categoryData.entries.map((entry) {
                  final value = entry.value["amount"] as double;
                  final color = entry.value["color"] as Color;
                  final percent = entry.value["percent"] as double;

                  return PieChartSectionData(
                    color: color,
                    value: value,
                    title: "${percent.toStringAsFixed(1)}%",
                    radius: 70,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

/// Summary Card Widget
class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            amount,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Expense Tile Widget
class ExpenseTile extends StatelessWidget {
  final String title;
  final double amount;
  final String date;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ExpenseTile({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    return Slidable(
      key: ValueKey(title + date),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.45,
        children: [
          _buildCircularAction(
            color: Colors.blue,
            icon: Icons.edit,
            label: "Edit",
            onTap: onEdit,
          ),
          const SizedBox(width: 12),
          _buildCircularAction(
            color: Colors.red,
            icon: Icons.delete,
            label: "Delete",
            onTap: onDelete,
          ),
        ],
      ),
      child: TRoundedContainer(
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.only(bottom: 12),
        showShadow: false,
        backgroundColor: isDark ? TColors.darkerGrey : TColors.lightGrey,
        child: ListTile(
          leading: Image.asset(
            TImages.recentExpenseImage,
            color: TColors.error,
            height: 32,
            width: 32,
          ),
          title: Text(
            title,
            style: textStyle.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            date,
            style: textStyle.bodySmall?.copyWith(
              color: isDark ? TColors.grey : TColors.darkGrey,
            ),
          ),
          trailing: Text(
            "₹$amount",
            style: textStyle.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? TColors.textWhite : TColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularAction({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return CustomSlidableAction(
      onPressed: (_) => onTap(),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}
