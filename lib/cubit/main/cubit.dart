import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:logging/logging.dart';

import 'package:toyvalley/data/model/apiResponse.dart';
import 'package:toyvalley/data/model/token.dart';
import 'package:toyvalley/data/model/user.dart';
import 'package:toyvalley/data/model/product.dart';
import 'package:toyvalley/data/model/products.dart';
import 'package:toyvalley/data/network/net_repository.dart';
import 'package:toyvalley/data/network/net_service.dart';
import 'package:toyvalley/data/const.dart';

import 'package:toyvalley/config/get_it.dart';
import 'package:toyvalley/config/notification.dart';

part 'state.dart';

class MainCubit extends Cubit<MainState> {
  final NetworkRepository networkRepository;
  final _logger = Logger('MainCubit');

  MainCubit([networkRepository])
    : networkRepository = networkRepository ?? getIt.get<NetworkRepository>(),
      super(MainState());

  void initialize() async {
    startVideo();

    String? deviceId = await getNewDeviceId();
    String secretKey = getIt.get<NetworkService>().secretKey;
    String signature = '';

    final ApiResponse result = await networkRepository.getSessionToken();
    if (result.success) {
      TokenData tokenData = TokenData.fromJson(result.data);
      String sessionToken = tokenData.sessionToken ?? '';

      var bytesSignature = utf8.encode(sessionToken + secretKey);
      signature = sha256.convert(bytesSignature).toString();

      getAccessToken(
        sessionToken: sessionToken,
        signature: signature,
        deviceId: deviceId ?? '',
      );
    } else if (result.data == noConnection) {
      emit(state.copyWith(screen: MainStateScreen.noConnection));
    }
  }

  void startVideo() async {
    emit(state.copyWith(screen: MainStateScreen.intro));
  }

  void getAccessToken({
    required String sessionToken,
    required String signature,
    required String deviceId,
  }) async {
    final ApiResponse response = await networkRepository.getAccessToken(
      sessionToken: sessionToken,
      signature: signature,
      deviceId: deviceId,
    );
    if (response.success) {
      TokenData tokenData = TokenData.fromJson(response.data);

      getIt.get<NetworkService>().saveAuthSession(tokenData.accessToken ?? '');

      await getUser();
      await sendFirebaseToken();
      startPushNotifications();
      verifyFirebaseSetup();
      getProducts(1);
    }
  }

  void verifyFirebaseSetup() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('new_products');
      _logger.info('Topic subscription successful');
    } catch (e) {
      _logger.severe('Firebase verification failed: $e');
    }
  }

  void startPushNotifications() async {
    try {
      final fcm = FCM();
      await fcm.setNotifications();

      // Listen for notification opens
      fcm.streamBackground.stream.listen((data) {
        _logger.info('Notification opened from background');
        getProducts(1); // Refresh products
      });

      fcm.streamTerminated.stream.listen((data) {
        _logger.info('Notification opened from terminated state');
        getProducts(1); // Refresh products
      });

      await FirebaseMessaging.instance.unsubscribeFromTopic('new_products');
      await FirebaseMessaging.instance.subscribeToTopic('new_products');

      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        _logger.warning('Push notifications not authorized');
        return;
      }
      _logger.info('Successfully subscribed to new_products topic');
    } catch (e) {
      _logger.severe('Failed to setup push notifications', e);
    }
  }

  void checkIfUserExistsAndGoToMain() async {
    if (state.user?.name?.isNotEmpty != true || state.user?.image == null) {
      emit(state.copyWith(screen: MainStateScreen.newUser));
    } else {
      toMain();
    }
  }

  void toMain() {
    if (state.paginatedProducts != null) {
      emit(state.copyWith(screen: MainStateScreen.main));
    } else {
      emit(state.copyWith(screen: MainStateScreen.loading));
    }
  }

  void sendAnalyticsEvent(int type, {int? seconds, required int id}) async {
    ApiResponse response = await networkRepository.sendAnalyticsEvent(
      id,
      type,
      seconds: seconds,
    );
    _logger.info(response.data);
  }

  void addToWishlist(int id) async {
    sendAnalyticsEvent(4, id: id);
    ApiResponse response = await networkRepository.addToWishlist(id);
    if (response.success) {
      getWishlistProducts(1);
    }

    //set locally isInUserProducts
    List<Product>? products = state.products;
    products?.firstWhere((element) => element.id == id).isInUserProducts = true;
    emit(state.copyWith(products: products));
  }

  void removeFromWishlist(int id) async {
    ApiResponse response = await networkRepository.removeFromWishlist(id);
    if (response.success) {
      getWishlistProducts(1);
    }
    //set locally isInUserProducts
    List<Product>? products = state.products;
    products?.firstWhere((element) => element.id == id).isInUserProducts =
        false;
    emit(state.copyWith(products: products));
  }

  void like(int id) async {
    sendAnalyticsEvent(5, id: id);
    List<Product> products = [];
    products.addAll(state.products!);
    products.firstWhere((element) => element.id == id).isLiked = true;
    emit(state.copyWith(products: products));
  }

  void dislike(int id) async {
    List<Product>? products = [];
    products.addAll(state.products!);
    products.firstWhere((element) => element.id == id).isLiked = false;
    emit(state.copyWith(products: products));
  }

  void refreshProducts() {
    List<Product>? products = state.products;
    emit(state.copyWith(products: products));
  }

  void changeTab(int index) {
    if (index == 2) {
      getWishlistProducts(1);
    }
    emit(state.copyWith(tabIndex: index));
  }

  void changeToyScreenState() {
    if (state.toyScreenState == ToyScreenState.feed) {
      emit(state.copyWith(toyScreenState: ToyScreenState.grid));
    } else {
      emit(state.copyWith(toyScreenState: ToyScreenState.feed));
    }
  }

  void checkNotificationSettings() async {
    ApiResponse response = await networkRepository.getNotification();
    if (response.success) {
      bool isEnabled = response.data['is_enabled'];
      if (!isEnabled) {
        _logger.info('Notifications are disabled in user settings');
      }
    }
  }

  Future sendFirebaseToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      _logger.info('Firebase Token Generated: $token');
      if (token == null) {
        _logger.warning('Failed to generate Firebase token');
        return;
      }

      final authToken = await getIt.get<NetworkService>().getJwt();
      if (authToken == null) {
        _logger.warning('No authentication token available');
        return;
      }

      ApiResponse response = await networkRepository.sendFirebaseToken(token);
      _logger.info('Firebase Token Send Response: ${response.success}');
      if (!response.success) {
        _logger.warning('Failed to send token to backend: ${response.data}');
      }
    } catch (e) {
      _logger.severe('Error in sendFirebaseToken', e);
    }
  }

  Future getUser() async {
    ApiResponse response = await networkRepository.getUser();
    if (response.success) {
      User user = User.fromJson(response.data);
      emit(state.copyWith(user: user));
    }
  }

  Future<String?> getNewDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // unique ID on Android
    }
    return null;
  }

  Future getNewProducts() async {
    //load more products
    int lastPage = state.paginatedProducts?.pagination?.lastPage ?? 1;
    int currentPage = state.paginatedProducts?.pagination?.currentPage ?? 1;
    List<Product> products = state.products ?? [];
    if (lastPage > currentPage) {
      await getProducts(currentPage + 1);
      state.paginatedProducts?.items?.forEach((element) {
        products.add(element);
      });
      emit(state.copyWith(products: products));
    }
  }

  Future getProducts(int page) async {
    ApiResponse response = await networkRepository.getProducts(page: page);
    if (response.success) {
      Products paginatedProducts = Products.fromJson(response.data);
      emit(state.copyWith(paginatedProducts: paginatedProducts));
      if (state.screen == MainStateScreen.loading) {
        emit(state.copyWith(screen: MainStateScreen.main));
      }
      if (page == 1) {
        emit(state.copyWith(products: paginatedProducts.items));
      }
    }
  }

  Future getWishlistProducts(int page) async {
    ApiResponse response = await networkRepository.getWishlist(page: page);
    if (response.success) {
      Products paginatedProducts = Products.fromJson(response.data);
      emit(
        state.copyWith(
          paginatedWishlistProducts: paginatedProducts,
          noConnection: false,
        ),
      );
      if (page == 1) {
        emit(state.copyWith(wishlistProducts: paginatedProducts.items));
      }
    } else if (response.data == noConnection) {
      emit(state.copyWith(noConnection: true));
    }
  }

  Future<Map<String, dynamic>?> getWishlistShareLink() async {
    try {
      ApiResponse response = await networkRepository.getWishlistShareLink();
      if (response.success && response.data != null) {
        final shareUrl = response.data['shareUrl'];
        final productsCount = response.data['productsCount'];

        if (shareUrl == null || productsCount == null) {
          return null;
        }

        return {
          'share_url': shareUrl.toString(),
          'products_count': productsCount as int,
        };
      }
      return null;
    } catch (e) {
      _logger.severe('Error getting wishlist share link', e);
      return null;
    }
  }

  Future getNewWishlistProducts() async {
    //load more wishlist products
    int lastPage = state.paginatedWishlistProducts?.pagination?.lastPage ?? 1;
    int currentPage =
        state.paginatedWishlistProducts?.pagination?.currentPage ?? 1;
    List<Product> products = state.wishlistProducts ?? [];
    if (lastPage > currentPage) {
      await getWishlistProducts(currentPage + 1);
      state.paginatedWishlistProducts?.items?.forEach((element) {
        products.add(element);
      });
      emit(state.copyWith(wishlistProducts: products));
    }
  }

  bool isFeedOpened() {
    if (state.toyScreenState == ToyScreenState.feed) {
      return true;
    } else {
      return false;
    }
  }
}
