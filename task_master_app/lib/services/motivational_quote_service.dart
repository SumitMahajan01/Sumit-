import 'dart:math';

class MotivationalQuoteService {
  static final List<String> _quotes = [
    "The secret of getting ahead is getting started.",
    "Don't watch the clock; do what it does. Keep going.",
    "The only way to do great work is to love what you do.",
    "Believe you can and you're halfway there.",
    "Success is not final, failure is not fatal: it is the courage to continue that counts.",
    "It does not matter how slowly you go as long as you do not stop.",
    "The future belongs to those who believe in the beauty of their dreams.",
    "Well done is better than well said.",
    "You are the master of your destiny.",
    "The harder you work for something, the greater you'll feel when you achieve it."
  ];

  String getDailyQuote() {
    // Use the day of the year to get a consistent quote for the whole day.
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final quoteIndex = dayOfYear % _quotes.length;
    return _quotes[quoteIndex];
  }
}
