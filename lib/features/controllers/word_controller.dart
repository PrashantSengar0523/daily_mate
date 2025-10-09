import 'dart:convert';
import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class WordController extends GetxController {

  var isLoading = false.obs;
  var hasError = false.obs;
  var word = "".obs;
  var meaning = "".obs;
  var example = "".obs;

  final String storageKey = "today_word";

  @override
  void onInit() {
    super.onInit();
    loadTodayWord();
  }

  /// 🔹 Check local storage first
  Future<void> loadTodayWord() async {
    final todayDate = DateTime.now().toIso8601String().substring(0, 10); // yyyy-MM-dd
    final cachedData = storageService.read(todayWord);

    if (cachedData != null && cachedData["date"] == todayDate) {
      // ✅ Already saved today’s word
      word.value = cachedData["word"];
      meaning.value = cachedData["meaning"];
      example.value = cachedData["example"];
    } else {
      // ✅ Fetch new word
      await fetchTodayWord();
    }
  }

  /// 🔹 Fetch from Dictionary API
 Future<void> fetchWord(String query) async {
  if (query.isEmpty) return;

  isLoading.value = true;
  hasError.value = false;

  try {
    final url = Uri.parse("https://api.dictionaryapi.dev/api/v2/entries/en/$query");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      word.value = data[0]["word"] ?? query;

      // Get first definition for meaning
      String definition = "No meaning found.";
      String exampleText = "No example available.";

      final meanings = data[0]["meanings"] as List?;
      if (meanings != null && meanings.isNotEmpty) {
        // Iterate meanings and definitions
        outerLoop:
        for (final meaningItem in meanings) {
          final definitions = meaningItem["definitions"] as List?;
          if (definitions != null && definitions.isNotEmpty) {
            for (final def in definitions) {
              // Take first definition available for meaning
              if (definition == "No meaning found." && def["definition"] != null) {
                definition = def["definition"];
              }

              // Take first example available
              if (def["example"] != null && def["example"].toString().trim().isNotEmpty) {
                exampleText = def["example"];
                break outerLoop; // stop as soon as we find an example
              }
            }
          }
        }
      }

      meaning.value = definition;
      example.value = exampleText;

      // Save to local storage
      final todayDate = DateTime.now().toIso8601String().substring(0, 10);
      storageService.write(storageKey, {
        "date": todayDate,
        "word": word.value,
        "meaning": meaning.value,
        "example": example.value,
      });
    } else {
      hasError.value = true;
      word.value = query;
      meaning.value = "No meaning found.";
      example.value = "No example available.";
    }
  } catch (e) {
    hasError.value = true;
    word.value = query;
    meaning.value = "No meaning found.";
    example.value = "No example available.";
  } finally {
    isLoading.value = false;
  }
}


  /// 🔹 Get word from list based on today’s day
  String getTodayWord() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return professionalWords[dayOfYear % professionalWords.length];
  }

  /// 🔹 Fetch and save today’s word
  Future<void> fetchTodayWord() async {
    final todayWord = getTodayWord();
    await fetchWord(todayWord);
  }
}




const professionalWords = [
  "Acumen",
  "Adaptability",
  "Alleviate",
  "Ameliorate",
  "Ambition",
  "Analytical",
  "Aptitude",
  "Articulate",
  "Aspiration",
  "Assertive",
  "Audacity",
  "Authenticity",
  "Balance",
  "Benchmark",
  "Bolster",
  "Brilliance",
  "Business",
  "Candor",
  "Capability",
  "Catalyst",
  "Civility",
  "Clarity",
  "Collaboration",
  "Commitment",
  "Compassion",
  "Competence",
  "Compliance",
  "Confidence",
  "Conducive",
  "Consensus",
  "Consistency",
  "Credibility",
  "Critical",
  "Culminate",
  "Curiosity",
  "Dedication",
  "Delegation",
  "Delineate",
  "Demeanor",
  "Diversity",
  "Diligence",
  "Diplomacy",
  "Discern",
  "Discipline",
  "Drive",
  "Efficacy",
  "Efficiency",
  "Elegance",
  "Empathy",
  "Empower",
  "Endorse",
  "Engagement",
  "Entrepreneurship",
  "Envision",
  "Ethics",
  "Excellence",
  "Exemplary",
  "Expedite",
  "Expertise",
  "Facilitate",
  "Fairness",
  "Fidelity",
  "Foresight",
  "Fortitude",
  "Framework",
  "Fulfillment",
  "Generosity",
  "Goal-oriented",
  "Gratitude",
  "Growth",
  "Harmony",
  "Honesty",
  "Holistic",
  "Humility",
  "Impeccable",
  "Inception",
  "Inclusion",
  "Industrious",
  "Influence",
  "Ingenuity",
  "Initiative",
  "Innovation",
  "Integrity",
  "Intellect",
  "Intuition",
  "Judicious",
  "Knowledge",
  "Leadership",
  "Learning",
  "Legitimacy",
  "Leverage",
  "Logic",
  "Longevity",
  "Lucid",
  "Mastery",
  "Maturity",
  "Meaningful",
  "Merit",
  "Meticulous",
  "Mindset",
  "Motivation",
  "Negotiation",
  "Networking",
  "Nimble",
  "Nurture",
  "Objective",
  "Optimism",
  "Organized",
  "Originality",
  "Outcome",
  "Ownership",
  "Passion",
  "Patience",
  "Perceptive",
  "Performance",
  "Persistence",
  "Persuasion",
  "Philanthropy",
  "Pioneering",
  "Planning",
  "Positivity",
  "Pragmatic",
  "Precision",
  "Preparedness",
  "Principled",
  "Prioritize",
  "Proactive",
  "Problem-solving",
  "Process",
  "Productivity",
  "Professionalism",
  "Progress",
  "Prosperity",
  "Punctuality",
  "Quality",
  "Rapport",
  "Recognition",
  "Reflective",
  "Reliability",
  "Resilience",
  "Resolution",
  "Resourceful",
  "Respect",
  "Responsibility",
  "Result-oriented",
  "Risk-taking",
  "Role-model",
  "Sacrifice",
  "Scalability",
  "Self-awareness",
  "Self-confidence",
  "Self-discipline",
  "Self-motivation",
  "Sensitivity",
  "Service",
  "Sincerity",
  "Skillset",
  "Smart",
  "Solution-oriented",
  "Sophistication",
  "Stability",
  "Stakeholder",
  "Standardization",
  "Strategy",
  "Strength",
  "Structure",
  "Success",
  "Sustainability",
  "Synergy",
  "Systematic",
  "Talent",
  "Teamwork",
  "Tenacity",
  "Thoroughness",
  "Time-management",
  "Tolerance",
  "Transparency",
  "Trust",
  "Understanding",
  "Unity",
  "Upstanding",
  "Value",
  "Versatility",
  "Vision",
  "Wisdom",
  "Work-ethic",
  "Zeal",
  // -----------  continue till 366 words -------------
  "Accountability",
  "Accuracy",
  "Achievement",
  "Adaptation",
  "Advancement",
  "Alignment",
  "Altruism",
  "Ambidextrous",
  "Analogy",
  "Anticipation",
  "Approachability",
  "Aspire",
  "Authentic",
  "Balance",
  "Benevolence",
  "Brainstorming",
  "Breakthrough",
  "Broad-minded",
  "Calculated",
  "Capacity",
  "Carefulness",
  "Challenge",
  "Charisma",
  "Clairvoyant",
  "Collaboration",
  "Composure",
  "Comprehension",
  "Concise",
  "Concentration",
  "Conscientious",
  "Constructive",
  "Consultative",
  "Continuous",
  "Coordination",
  "Courage",
  "Creativity",
  "Decisiveness",
  "Dependability",
  "Determination",
  "Differentiation",
  "Diplomatic",
  "Discerning",
  "Distinctive",
  "Dynamic",
  "Earnest",
  "Empirical",
  "Endurance",
  "Enthusiasm",
  "Entrepreneurial",
  "Equality",
  "Equity",
  "Exemplify",
  "Exploration",
  "Fair-minded",
  "Farsighted",
  "Flexibility",
  "Focus",
  "Forward-thinking",
  "Fulfilled",
  "Generative",
  "Goal-setting",
  "Goodwill",
  "Grounded",
  "Habitual",
  "Hands-on",
  "Hopefulness",
  "Humanity",
  "Impactful",
  "Improvement",
  "Independence",
  "Influential",
  "Initiator",
  "Inspirational",
  "Integrity-driven",
  "Intellectual",
  "Inventive",
  "Joyfulness",
  "Judgment",
  "Kindness",
  "Knowledgeable",
  "Logical",
  "Long-term",
  "Meaning",
  "Memorable",
  "Mentorship",
  "Mindful",
  "Modernization",
  "Momentum",
  "Mutual",
  "Navigational",
  "Nonjudgmental",
  "Objective-driven",
  "Observant",
  "Open-minded",
  "Opportunity",
  "Organizational",
  "Outcome-driven",
  "Outreach",
  "Overcome",
  "Partnership",
  "Passionate",
  "Patient",
  "Pioneering",
  "Practical",
  "Prepared",
  "Prioritization",
  "Problem-solver",
  "Professional",
  "Progressive",
  "Promise",
  "Prudence",
  "Purpose",
  "Quality-driven",
  "Rational",
  "Receptive",
  "Reflective",
  "Reinforcement",
  "Reliant",
  "Reputation",
  "Resolution-oriented",
  "Respectful",
  "Responsive",
  "Results-driven",
  "Rigorous",
  "Risk-aware",
  "Role-oriented",
  "Savvy",
  "Scalable",
  "Self-control",
  "Self-improvement",
  "Self-reliance",
  "Service-oriented",
  "Skillful",
  "Sociable",
  "Solution-focused",
  "Sophisticated",
  "Sound",
  "Strategic",
  "Strengthened",
  "Structured",
  "Supportive",
  "Sustainable",
  "Systematic",
  "Talented",
  "Team-oriented",
  "Thorough",
  "Timely",
  "Transparent",
  "Trustworthy",
  "Unbiased",
  "Unique",
  "Valuable",
  "Versatile",
  "Visionary",
  "Well-being",
  "Wholehearted",
  "Wise",
  "Work-oriented",
  "Zealous",
];
