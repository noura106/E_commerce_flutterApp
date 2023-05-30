import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'dart:convert';

import 'package:shop_app/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
      'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
      'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];
  String authToken='';
  String  userId='';


  getData(String authtok, String uId, List<Product> products) {
    authToken = authtok;
    userId = uId;
    _items = products;
    notifyListeners();
  }

  List<Product> get items {
    return [..._items];
  }

  List <Product> get favouritesItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  Product findById(String id) {
    return items.firstWhere((prod) => prod.id == id);
  }

  // get data from database
  Future <void> fetchAndSetProduct([bool filterByUser = false]) async {
    final filteredString = filterByUser
        ? 'orderBy = "creatorId"&equalTo="$userId"'
        : '';
    var url = 'https://shop-d6e3d-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filteredString';
    try {
      final res = await http.get(Uri.parse(url));
      final extractedData = json.decode(res.body) as Map <String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
      'https://shop-d6e3d-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favRes = await http.get(Uri.parse(url));
      final favData = json.decode(favRes.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            title: prodData['title'],
            id: prodId,
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            price: prodData['[price'],
            isFavourite: favData == null ? false : favData[prodId]!));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      //throw error;
    }
  }

  Future <void> addProduct(Product product) async {
    final url = 'https://shop-d6e3d-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final res = await http.post(Uri.parse(url), body: json.encode({
        'title': product.title,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'creatorId': userId
      }));
      final newProduct = Product(
        id: json.decode(res.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,);
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      throw e ;
    }
  }
  Future <void> updateProduct (Product newProduct,String id) async{
    final prodIndex =_items.indexWhere((prod) => prod.id ==id);
    if(prodIndex>=0) {
      final url = 'https://shop-d6e3d-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      final res =await http.patch(Uri.parse(url),body: json.encode({
        'title' : newProduct.title,
        'description' : newProduct.description,
        'imageUrl' : newProduct.imageUrl,
        'price' : newProduct.price
      }));
      _items[prodIndex] =newProduct;
      notifyListeners();
    } else print ("... ");
  }
  Future<void> deleteProduct(String id) async {
    final url = 'https://shop-d6e3d-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex=_items.indexWhere((prod) => prod.id==id);
    Product? existingProduct=_items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final res =await http.delete(Uri.parse(url));
    if(res.statusCode>=400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
     existingProduct=null;

  }
}