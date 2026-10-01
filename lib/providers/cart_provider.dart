import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../helpers/db_helper.dart';

class CartProvider with ChangeNotifier {
  List<Product> _products = [];
  List<CartItem> _cartItems = [];
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  List<CartItem> get cartItems => _cartItems;
  String get selectedCategory => _selectedCategory;

  List<Product> get filteredProducts {
    return _products.where((prod) {
      final matchesSearch = prod.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Semua' || prod.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  int get totalItemCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get shippingFee => _cartItems.isNotEmpty ? 15000.0 : 0.0;
  double get grandTotal => subtotalPrice + shippingFee;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> fetchAllData() async {
    _products = await DBHelper.getProducts();
    _cartItems = await DBHelper.getCartItems();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await DBHelper.insertProduct(product);
    await fetchAllData();
  }

  Future<void> addToCart(Product product) async {
    int index = _cartItems.indexWhere((item) => item.productId == product.id);
    if (index != -1) {
      _cartItems[index].quantity += 1;
      await DBHelper.updateCartQuantity(_cartItems[index].id!, _cartItems[index].quantity);
    } else {
      CartItem newItem = CartItem(
        productId: product.id!,
        name: product.name,
        price: product.price,
        quantity: 1,
      );
      await DBHelper.insertCartItem(newItem);
    }
    await fetchAllData();
  }

  Future<void> incrementQuantity(CartItem item) async {
    item.quantity += 1;
    await DBHelper.updateCartQuantity(item.id!, item.quantity);
    notifyListeners();
  }

  Future<void> decrementQuantity(CartItem item) async {
    if (item.quantity > 1) {
      item.quantity -= 1;
      await DBHelper.updateCartQuantity(item.id!, item.quantity);
    } else {
      await DBHelper.deleteCartItem(item.id!);
    }
    await fetchAllData();
  }

  Future<void> removeItem(int id) async {
    await DBHelper.deleteCartItem(id);
    await fetchAllData();
  }

  Future<void> checkout() async {
    await DBHelper.clearCart();
    await fetchAllData();
  }
}