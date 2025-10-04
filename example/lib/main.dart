import 'package:object_finder/object_finder.dart';

void main() {
  final Map<String, dynamic> userData = {
    "id": "101",
    "active": "true",
    "balance": "250.75",
    "tags": ["vip", "loyal"],
    "purchases": [
      {"item": "Book", "price": "12.99"},
      {"item": "Pen", "price": "2.50"},
    ]
  };

  // ✅ Basic conversions
  final int id = userData.find<int>(key: "id"); // → 101
  final bool active = userData.find<bool>(key: "active"); // → true
  final double balance = userData.find<double>(key: "balance"); // → 250.75

  // ✅ List conversions
  final tags = userData.finds<String>(key: "tags"); // → ["vip", "loyal"]

  // ✅ List of map handling
  final purchases = userData.finds<Map<String, dynamic>>(key: "purchases");
  final firstItem = purchases.first.find<String>(key: "item"); // → "Book"
  final firstPrice = purchases.first.find<double>(key: "price"); // → 12.99

  // ✅ Default values
  final nickname = userData.findOrNull<String>(
      key: "nickname", defaultValue: "Guest"); // → "Guest"

  print('ID: $id');
  print('Active: $active');
  print('Balance: $balance');
  print('Tags: $tags');
  print('First item: $firstItem');
  print('First price: $firstPrice');
  print('Nickname: $nickname');
}
