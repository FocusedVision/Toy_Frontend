import 'package:bloc/bloc.dart';
import 'package:toyvalley/config/get_it.dart';
import 'package:toyvalley/data/const.dart';
import 'package:toyvalley/data/model/apiResponse.dart';
import 'package:toyvalley/data/model/product.dart';
import 'package:toyvalley/data/network/net_repository.dart';
import 'package:logging/logging.dart';
part 'state.dart';

class ToyCubit extends Cubit<ToyState> {
  final _logger = Logger('Toy');

  ToyCubit()
    : networkRepository = getIt.get<NetworkRepository>(),
      super(ToyState());

  final NetworkRepository networkRepository;

  void getToyById(int id) async {
    emit(state.copyWith(isLoading: true, noConnection: false));
    ApiResponse response = await networkRepository.getProductById(id);
    if (response.success) {
      Product product = Product.fromJson(response.data);
      sendAnalyticsEvent(0, id: product.id);
      _logger.info('ProductID', product.id);
      emit(state.copyWith(currentProduct: product, isLoading: false));
    } else {
      if (response.data == noConnection) {
        emit(state.copyWith(noConnection: true));
      }
    }
  }

  String getInfoUrl(int id) => networkRepository.getInfoUrl(id);

  void sendAnalyticsEvent(int type, {int? seconds, required int id}) async {
    ApiResponse response = await networkRepository.sendAnalyticsEvent(
      id,
      type,
      seconds: seconds,
    );
    _logger.info('GetURL Response', response);
  }
}
