import 'package:intl/intl.dart';

class TFormatter {
static String formatDate(DateTime? date) {
  date ??= DateTime.now();
  return DateFormat('d MMMM, y').format(date); // e.g., "6 June, 2025"
}

static String formatDate2(DateTime? date) {
  date ??= DateTime.now();
  return DateFormat('d MMM').format(date); // e.g., "6 June"
}

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount); // Customize the currency locale and symbol as needed
  }

  static String formatPhoneNumber(String phoneNumber) {
    // Assuming a 10-digit US phone number format: (123) 456-7890
    if (phoneNumber.length == 10) {
      return '(${phoneNumber.substring(0, 3)}) ${phoneNumber.substring(3, 6)} ${phoneNumber.substring(6)}';
    } else if (phoneNumber.length == 11) {
      return '(${phoneNumber.substring(0, 4)}) ${phoneNumber.substring(4, 7)} ${phoneNumber.substring(7)}';
    }
    // Add more custom phone number formatting logic for different formats if needed.
    return phoneNumber;
  }

  // Not fully tested.
  static String internationalFormatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters from the phone number
    var digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Extract the country code from the digitsOnly
    String countryCode = '+${digitsOnly.substring(0, 2)}';
    digitsOnly = digitsOnly.substring(2);

    // Add the remaining digits with proper formatting
    final formattedNumber = StringBuffer();
    formattedNumber.write('($countryCode) ');

    int i = 0;
    while (i < digitsOnly.length) {
      int groupLength = 2;
      if (i == 0 && countryCode == '+1') {
        groupLength = 3;
      }

      int end = i + groupLength;
      formattedNumber.write(digitsOnly.substring(i, end));

      if (end < digitsOnly.length) {
        formattedNumber.write(' ');
      }
      i = end;
    }

    return formattedNumber.toString();
  }

static String orderStatusFormat(String orderStatus) {
  switch (orderStatus) {
    case "pending":
      return "Pending";
    case "approved":
      return "Approved";
    case "ssRejected":
      return "Ss Rejected";
    case "paymentSsUpload":
      return "Verifying";
    case "cancelled":
      return "Cancelled";
    case "orderPlaced":
      return "Order Placed";
    case "orderPacked":
      return "Order Packed";
    case "shipping":
      return "Shipped";
    case "homeDelivery":
      return "Home Delivery";
    case "lorryPay":
      return "Lorry Pay";
    case "outForDelivery":
      return "Out For Delivery";
    case "completed":
      return "Delivered";
    default:
      return orderStatus;
  }
}

}
