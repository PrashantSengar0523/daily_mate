// ignore_for_file: unused_import

import 'package:daily_mate/common/widgets/app_button/t_app_button.dart';
import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/common/widgets/text_fields/text_field.dart';
import 'package:daily_mate/features/controllers/holiday_controller.dart';
import 'package:daily_mate/features/controllers/user_event_controller.dart';
import 'package:daily_mate/features/views/holidays/holidays_view.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final HolidayController holidayController = Get.put(HolidayController());
  final UserEventController userEventController = Get.put(
    UserEventController(),
  );

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    // final isDark = THelperFunctions.isDarkMode(context);
    final monthNames = [
  TTexts.january.tr,
  TTexts.february.tr,
  TTexts.march.tr,
  TTexts.april.tr,
  TTexts.may.tr,
  TTexts.june.tr,
  TTexts.july.tr,
  TTexts.august.tr,
  TTexts.september.tr,
  TTexts.october.tr,
  TTexts.november.tr,
  TTexts.december.tr,
];

final currentMonthName = monthNames[DateTime.now().month - 1];

    return Scaffold(
      appBar: TCommonAppBar(
        appBarWidget: Row(
          children: [
            Text(
              TTexts.calendar.tr,
              style: textStyle.titleMedium?.copyWith(
                color: TColors.textWhite,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          /// Pure calendar
          Obx(() {
            final eventDates = userEventController.getAllEventDates();

            return TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                final eventList = userEventController.getEventsByDate(
                  selectedDay,
                );
                if (eventList.isNotEmpty) {
                  TDialogs.defaultDialog(
                    context: context,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          eventList.map((event) {
                            return ListTile(
                              leading: const Icon(Icons.event_note),
                              title: Text(event.title),
                              subtitle: Text(
                                DateFormat(
                                  'd MMMM, y',
                                ).format(event.dateOfEvent),
                              ),
                            );
                          }).toList(),
                    ),
                  );
                }
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: TColors.primary,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final isEventDay = eventDates.any((d) => isSameDay(d, day));
                  final isToday = isSameDay(day, DateTime.now());
                  final isSelected = isSameDay(day, _selectedDay);

                  Color? bgColor;
                  if (isToday) {
                    bgColor = TColors.primary;
                  } else if (isEventDay) {
                    bgColor = TColors.secondary;
                  } else if (isSelected) {
                    bgColor = Colors.transparent;
                  }

                  return Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        color:
                            (isToday || isEventDay)
                                ?(Colors.white)
                                : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildCard(
                          context,
                          title: TTexts.allHolidays.tr,
                          icon: Icons.calendar_month,
                          titleIconColor: Colors.deepOrange.shade700,
                          lightColors: [Colors.orange.shade100, Colors.white],
                          darkColors: [
                            Colors.deepOrange.shade400,
                            Colors.deepOrange.shade700,
                          ],
                          onTap: () {
                            Get.to(() => HolidaysView());
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildCard(
                          context,
                          title: TTexts.addEvent.tr,
                          icon: Icons.add_circle_outline,
                          titleIconColor: Colors.green.shade800,
                          lightColors: [
                            Colors.greenAccent.shade100,
                            Colors.white,
                          ],
                          darkColors: [
                            Colors.teal.shade600,
                            Colors.green.shade800,
                          ],
                          onTap: () {
                            showAddUserEvent();
                          },
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _buildCard(
                          context,
                          title: "$currentMonthName ${TTexts.holidays.tr}",
                          icon: Icons.calendar_today_outlined,
                          titleIconColor: Colors.blue.shade900,
                          lightColors: [
                            Colors.lightBlue.shade100,
                            Colors.blue.shade50,
                          ],
                          darkColors: [
                            Colors.indigo.shade700,
                            Colors.blue.shade900,
                          ],
                          onTap: () {
                            showCurrentMonthHolidayss();
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildCard(
                          context,
                          title: TTexts.yourEvents.tr,
                          icon: Icons.event_available_outlined,
                          titleIconColor: Colors.deepPurple.shade900,
                          lightColors: [
                            Colors.purple.shade100,
                            Colors.pink.shade50,
                          ],
                          darkColors: [
                            Colors.purple.shade700,
                            Colors.deepPurple.shade900,
                          ],
                          onTap: () {
                            showAllUserEvents();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showAddUserEvent({UserEventModel? event}) {
    final titleController = TextEditingController(text: event?.title ?? '');
    final dateController = TextEditingController(
      text:
          event != null
              ? DateFormat('d MMMM, y').format(event.dateOfEvent)
              : DateFormat('d MMMM, y').format(DateTime.now()),
    );

    DateTime selectedDate = event?.dateOfEvent ?? DateTime.now();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    TDialogs.defaultDialog(
      context: context,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  event == null ? TTexts.addEvent.tr : TTexts.editEvent.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// Title field
            TTextField(
              controller: titleController,
              hintText: TTexts.title.tr,
              maxLength: 40,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return TTexts.emptyFieldValidation.tr;
                }
                if (val.trim().length > 40) {
                  return TTexts.title40Chars.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            /// Date field
            TTextField(
              controller: dateController,
              hintText: TTexts.date.tr,
              readOnly: true,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return TTexts.emptyFieldValidation.tr;
                }
                return null;
              },
              suffixIcon: InkWell(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                    dateController.text = DateFormat(
                      'd MMMM, y',
                    ).format(selectedDate);
                  }
                },
                child: const Icon(Icons.date_range_rounded),
              ),
            ),
            const SizedBox(height: 20),

            /// Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TAppOutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  height: 36,
                  text: TTexts.cancel.tr,
                ),
                const SizedBox(width: 12),
                TAppButton(
                  text: TTexts.save.tr,
                  height: 36,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    if (event == null) {
                      userEventController.addEvent(
                        titleController.text.trim(),
                        selectedDate,
                      );
                    } else {
                      userEventController.editEvent(
                        event.id,
                        titleController.text.trim(),
                        selectedDate,
                      );
                    }

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showAllUserEvents() {
    final userEvents = userEventController.userEvents; // Fetch all events

    TDialogs.defaultDialog(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TTexts.yourEvents.tr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: TSizes.fontSizeMd,
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(height: TSizes.spaceBtwItems),

          /// Scrollable list with max height 200
          SizedBox(
            height: 200,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              shrinkWrap: true,
              itemCount: userEvents.length,
              itemBuilder: (context, index) {
                final event = userEvents[index];
                return ListTile(
                  title: Text(event.title),
                  subtitle: Text(
                    DateFormat('d MMMM, y').format(event.dateOfEvent),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Edit button
                      InkWell(
                        child: const Icon(Icons.edit, color: Colors.blue),
                        onTap: () {
                          Navigator.pop(context); // close dialog
                          showAddUserEvent(event: event); // open edit dialog
                        },
                      ),
                      const SizedBox(width: 8),

                      /// Delete button
                      InkWell(
                        child: const Icon(Icons.delete, color: Colors.red),
                        onTap: () {
                          userEventController.deleteEvent(event.id);
                          Navigator.pop(context); // close dialog
                          Future.delayed(const Duration(milliseconds: 200), () {
                            showAllUserEvents(); // reopen updated list
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showCurrentMonthHolidayss() {
    final currentHolidays = holidayController.currentMonthHolidays;

    TDialogs.defaultDialog(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${DateFormat('MMMM').format(DateTime.now())} Holidays",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Scrollable list with max height 200
          SizedBox(
            height: 200,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: currentHolidays.length,
              itemBuilder: (context, index) {
                final holiday = currentHolidays[index];

                // Parse date string to DateTime
                final holidayDate =
                    DateTime.tryParse(holiday.date) ?? DateTime.now();

                return ListTile(
                  title: Text(holiday.name),
                  subtitle: Text(DateFormat('d MMMM, y').format(holidayDate)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required Color titleIconColor,
    required String title,
    required IconData icon,
    required List<Color> lightColors,
    required List<Color> darkColors,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        // padding: EdgeInsets.symmetric(vertical: TSizes.md),
        height: 120,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDark ? darkColors : lightColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDark ? TColors.white : titleIconColor,
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              textAlign: TextAlign.center,
              title,
              style: textStyle.titleMedium?.copyWith(
                color: isDark ? TColors.textWhite : titleIconColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
