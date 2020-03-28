
import 'package:emergency/domain/entities/Country.dart';
import 'package:emergency/domain/repositories/CountryRepositoryType.dart';
import 'package:emergency/domain/repositories/UserRepositoryType.dart';
import 'package:emergency/domain/usecases/CountryUseCase.dart';

class CountryService extends CountryUseCase {

  CountryRepositoryType countryRepository;
  UserRepositoryType userRepository;
  CountryService(this.countryRepository, this.userRepository);

  @override
  Future<List<Country>> allCountries() async {
    var countries = await countryRepository.countries();
    return countries;
  }

  @override
  Future<List<Country>> subscribedCountries() async {
    var userId = await userRepository.userId();
    return countryRepository.countriesBy(userId);
  }

  @override
  Future<List<Country>> searchCountries(String name) async {
    var countries = await countryRepository.countries();
    return countries.where((f) => f.name.startsWith(name));
  }

  @override
  void subscribeNews(Country country, DateTime from, DateTime to) {
    countryRepository.subscribe(country);
  }

  @override
  void unsubscribe(Country country) {
    countryRepository.unsubscribe(country);
  }
}