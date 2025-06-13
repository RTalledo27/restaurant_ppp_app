import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/cart_item.dart';
import '../domain/entities/menu_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(MenuItem item, {int quantity = 1, String note = ''}) {
    final index = state.indexWhere((c) => c.item.id == item.id && c.note == note);
    if (index >= 0) {
      final existing = state[index];
      state = [
        ...state.sublist(0, index),
        existing.copyWith(quantity: existing.quantity + quantity),
        ...state.sublist(index + 1),
      ];
    } else {
      state = [...state, CartItem(item: item, quantity: quantity, note: note)];
    }
  }

  void updateQuantity(CartItem cartItem, int quantity) {
    final index = state.indexOf(cartItem);
    if (index >= 0) {
      state = [
        ...state.sublist(0, index),
        cartItem.copyWith(quantity: quantity),
        ...state.sublist(index + 1),
      ];
    }
  }

  void removeItem(CartItem cartItem) {
    state = List.of(state)..remove(cartItem);
  }

  void clear() => state = [];
}

final cartProvider =
StateNotifierProvider<CartNotifier, List<CartItem>>((ref) => CartNotifier());