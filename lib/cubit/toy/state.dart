part of 'cubit.dart';

class ToyState {
  Product? currentProduct;
  bool isLoading;
  bool noConnection;

  ToyState({
    this.currentProduct,
    this.isLoading = false,
    this.noConnection = false,
  });

  ToyState copyWith({
    bool? isLoading,
    bool? noConnection,
    Product? currentProduct,
  }) {
    return ToyState(
      isLoading: isLoading ?? this.isLoading,
      noConnection: noConnection ?? this.noConnection,
      currentProduct: currentProduct ?? this.currentProduct,
    );
  }
}
