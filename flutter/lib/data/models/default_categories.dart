/// Default subcategory lists used across the app for expense and income entries.
library;

const List<Map<String, dynamic>> kExpenseSubcategories = [
  {'name': 'Food & Dining', 'icon': 'restaurant'},
  {'name': 'Groceries', 'icon': 'shopping_cart'},
  {'name': 'Transport', 'icon': 'directions_car'},
  {'name': 'Shopping', 'icon': 'shopping_bag'},
  {'name': 'Bills & Utilities', 'icon': 'receipt'},
  {'name': 'Rent / Housing', 'icon': 'home'},
  {'name': 'Health', 'icon': 'favorite'},
  {'name': 'Entertainment', 'icon': 'movie'},
  {'name': 'Education', 'icon': 'school'},
  {'name': 'Travel', 'icon': 'flight_takeoff'},
  {'name': 'Subscriptions', 'icon': 'subscriptions'},
  {'name': 'Personal Care', 'icon': 'self_improvement'},
  {'name': 'Family', 'icon': 'family_restroom'},
  {'name': 'Other', 'icon': 'category'},
];

const List<Map<String, dynamic>> kIncomeSubcategories = [
  {'name': 'Salary', 'icon': 'work'},
  {'name': 'Freelance', 'icon': 'laptop'},
  {'name': 'Business', 'icon': 'business'},
  {'name': 'Investment', 'icon': 'trending_up'},
  {'name': 'Gift', 'icon': 'card_giftcard'},
  {'name': 'Other Income', 'icon': 'attach_money'},
];

const List<String> kSupportedCurrencies = [
  'TND',
  'EUR',
  'USD',
  'GBP',
  'MAD',
  'DZD',
  'SAR',
  'AED',
  'JPY',
  'CNY',
];

const Map<String, String> kCurrencySymbols = {
  'TND': 'TND',
  'EUR': '€',
  'USD': '\$',
  'GBP': '£',
  'MAD': 'MAD',
  'DZD': 'DZD',
  'SAR': 'SAR',
  'AED': 'AED',
  'JPY': '¥',
  'CNY': '¥',
};

const List<String> kRegions = [
  'Tunisia',
  'France',
  'United States',
  'United Kingdom',
  'Morocco',
  'Algeria',
  'Saudi Arabia',
  'UAE',
  'Germany',
  'Spain',
  'Italy',
  'Canada',
  'Australia',
  'Japan',
  'China',
  'Other',
];
