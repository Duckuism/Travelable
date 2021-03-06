import '../../../../../core/networking/api_provider.dart';
import '../../../domain/entities/country.dart';
import '../../../domain/entities/notice.dart';
import '../../datasources/country_remote_data_source.dart';
import 'models/request/countries_get_request_model.dart';
import 'models/request/country_get_request_model.dart';
import 'models/request/country_pin_post_request_model.dart';
import 'models/request/country_unpin_post_request_model.dart';
import 'models/request/notices_get_request_model.dart';
import 'models/response/countries_get_response_model.dart';
import 'models/response/country_get_response_model.dart';
import 'models/response/notices_get_response_model.dart';
import 'requests/countries_get_request.dart';
import 'requests/country_get_request.dart';
import 'requests/country_pin_post_request.dart';
import 'requests/country_unpin_post_request.dart';
import 'requests/notices_get_request.dart';

class CountryRemoteRepository implements CountryRemoteDataSource {
  final ApiProviderProtocol provider;

  CountryRemoteRepository(this.provider);

  @override
  Future<List<Country>> getCountries() async {
    final requestModel = CountriesGetRequestModel();
    final response = await provider.send(CountriesGetRequest(requestModel));
    return CountriesGetResponseModel.fromMap(response).countries;
  }

  @override
  Future<Country> getCountryBy(String countryId) async {
    final requestModel = CountryGetRequestModel(countryId);
    final response = await provider.send(CountryGetRequest(requestModel));
    return CountryGetResponseModel.fromMap(response).country;
  }

  @override
  Future<void> pinCountry(String countryId) async {
    final requestModel = CountryPinPostRequestModel(countryId);
    final response = await provider.send(CountryPinPostRequest(requestModel));
    return null;
  }

  @override
  Future<void> unpinCountry(String countryId) async {
    final requestModel = CountryUnpinPostRequestModel(countryId);
    final response = await provider.send(CountryUnpinPostRequest(requestModel));
    return null;
  }

  @override
  Future<List<Notice>> getNotices() async {
    final requestModel = NoticesGetRequestModel();
    final response = await provider.send(NoticesGetRequest(requestModel));
    return NoticesGetResponseModel.fromMap(response).notices;
  }
}
