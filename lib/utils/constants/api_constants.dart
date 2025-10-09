
import 'package:daily_mate/utils/dio/dio_client.dart';
import 'package:daily_mate/utils/local_storage/storage_utility.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// live URL
String appApiBaseUrl = "https://appapi.bigbangcrackers.com/api/";


/// keys and value
String authTokenKey = 'AUTH_TOKEN';
String userIdKey = 'USER_ID';
String isFirstTimeOnboardKey = 'FIRST_TIME_ONBOARD';

// Locations
String currentLat = "CURRENT_LAT";
String currentLong = "CURRENT_LONG";
String nearbyPlaces = "CURRENT_NEARBY_PLACES";


String? authToken;
String? userId;

// Weather and AQI
String temp = "TEMP";
String city = "CITY";
String condition = "CONDITION";
String humidity = "HUMIDITY";
String wind = "WIND";
String aqi = "AQI";
String pm25 = "PM2.5";
String pm10 = "PM10";
String todayForecastKey = "TODAYS_FORECAST";
String fiveDayForecastKey = "LAST_FORECAST";
String lastFetchedDateKey = "LAST_FETCHED_DATE";

String dailydigestNotificationKey = "morning_digest_scheduled";


String yearlyHolidays = "YEARLY_HOLIDAYS";

String todayDay = "QUOTE_OF_THE_DAY";

String todayWord = "TODAY_WORD";

String historyEvents = "HISTORY_EVENTS";


String waterRemiderParentIdKey = "WATER_REMIDNER_ID";
String waterRemiderTotalCupsKey = "WATER_REMIDNER_TOTAL_CUPS";
String exerciseReminderIdKey = "EXERCISE_REMIDNER_ID";
String medicineRemiderIdKey = "MEDICINE_REMIDNER_ID";
String notesIdKey = "NOTES_ID_KEY";

String miniPodcastKey = "MINI_PODCAST_KEY"; 

/// Admin keys
String teddyAPIKey = "fcb1fc4b560ce4cc9a8dc67a6000f049d7c0d256cec8c4805d59f1c5a468552ffcf7f658a97fc508852de3d3767ddf287";
int teddyUserIdKey = 3369;

/// single tone instance
StorageService storageService = StorageService();
NetworkClient networkClient = NetworkClient();
Dio dio = Dio();

  const zodiacSigns = [
  "Aries",
  "Taurus",
  "Gemini",
  "Cancer",
  "Leo",
  "Virgo",
  "Libra",
  "Scorpio",
  "Sagittarius",
  "Capricorn",
  "Aquarius",
  "Pisces",
];

const List<String> availableFonts = [
  'Roboto',
  'Lobster',
  'Pacifico',
  'Raleway',
  'Open Sans',
  'Montserrat',
  'Dancing Script',
  'Great Vibes',
  'Poppins',
  'Playfair Display',
  'Oswald',
  'Merriweather',
  'Nunito',
  'Josefin Sans',
  'Bebas Neue',
  'Caveat',
  'Amatic SC',
  'Shadows Into Light',
  'Sacramento',
  'Cinzel',
];

const List<Color> availableColors = [
  Colors.white,
  Colors.black,
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.purple,
  Colors.pink,
  Colors.teal,
  Colors.indigo,
  Colors.cyan,
  Colors.amber,
  Colors.lime,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.deepPurple,
  Colors.blueGrey,
  Colors.indigoAccent,
  Colors.pinkAccent,
  Colors.orangeAccent,
  Colors.lightBlueAccent,
  Colors.greenAccent,
];

