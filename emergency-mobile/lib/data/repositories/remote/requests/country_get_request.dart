import 'package:emergency/data/repositories/remote/models/request/country_get_request_model.dart';
import 'package:emergency/data/repositories/remote/networking/content_encoding.dart';
import 'package:emergency/data/repositories/remote/networking/http_method.dart';

import '../networking/http_request.dart';

class CountryGetRequest extends HttpRequestProtocol {
  final CountryGetRequestModel requestModel;

  CountryGetRequest(this.requestModel);

  @override
  String get baseUrl => 'http://emergency.podo.world:8080/api';

  @override
  ContentEncoding get contentEncoding => ContentEncoding.url;

  @override
  Map<String, String> get headers => {
        "content-type": "application/json",
        "accept": "application/json",
      };

  @override
  HttpMethod get method => HttpMethod.GET;

  @override
  Map<String, dynamic> get parameters => requestModel.toJson();

  @override
  String get path => '/countries/${requestModel.countryId}';
}