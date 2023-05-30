import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavourite = false});

  void _setfavValue(newValue) {
    isFavourite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavouriteStatus(String taken, String userId) async {
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url='https://shop-d6e3d-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$taken';
    ;
    try {
      final res =
          await http.put(Uri.parse(url), body: json.encode(isFavourite));
      if (res.statusCode >= 400) {
        // an error occured
        _setfavValue(oldStatus);
      }
    } catch (e) {}
  }
}
