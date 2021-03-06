import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:emergency/features/country/domain/usecases/get_country_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/util/keyword_validator.dart';
import '../../domain/entities/country.dart';
import '../../domain/usecases/get_all_countries_usecase.dart';
import '../../domain/usecases/get_indexing_usecase.dart';
import '../../domain/usecases/search_countries_usecase.dart';

part 'country_event.dart';
part 'country_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE = 'Failure';

class CountryBloc extends Bloc<CountryEvent, CountryState> {
  final GetAllCountriesUseCase allCountriesUseCase;
  final GetCountryUseCase countryUseCase;
  final SearchCountriesUseCase searchCountriesUseCase;
  final GetIndexingUseCase indexing;
  final KeywordValidator validator;

  CountryBloc(
      {@required this.allCountriesUseCase,
      @required this.countryUseCase,
      @required this.searchCountriesUseCase,
      @required GetIndexingUseCase indexingUseCase,
      @required this.validator})
      : assert(allCountriesUseCase != null),
        assert(countryUseCase != null),
        assert(searchCountriesUseCase != null),
        assert(indexingUseCase != null),
        assert(validator != null),
        indexing = indexingUseCase;

  @override
  CountryState get initialState => Empty();

  @override
  Stream<CountryState> mapEventToState(
    CountryEvent event,
  ) async* {
    if (event is GetCountrySearchResult) {
      final inputEither = validator.validateSearchKeyword(event.keyword);
      yield* inputEither.fold(
        (failure) async* {
          yield Error(message: INVALID_INPUT_FAILURE_MESSAGE);
        },
        (keyword) async* {
          yield Loading();
          if (keyword.isEmpty) {
            final failureOrCountries = await allCountriesUseCase(NoParams());
            final failureOrIndexing = await indexing(NoParams());
            yield* _eitherAllLoadedOrErrorState(
                failureOrCountries, failureOrIndexing);
          } else {
            final failureOrCountries =
                await searchCountriesUseCase(SearchParams(keyword));
            yield* _eitherMatchingLoadedOrErrorState(failureOrCountries);
          }
        },
      );
    } else if (event is GetCountryDetail) {
      final failureOrCountry =
          await countryUseCase(GetCountryParams(event.countryId));
      yield* _eitherDetailSheetOrErrorState(failureOrCountry);
    }
  }

  Stream<CountryState> _eitherAllLoadedOrErrorState(
    Either<Failure, List<Country>> failureOrCountries,
    Either<Failure, List<String>> failureOrIndexing,
  ) async* {
    yield* failureOrCountries.fold(
      (failure) async* {
        yield Error(message: _mapFailureToMessage(failure));
      },
      (countries) async* {
        yield* failureOrIndexing.fold((faliure) async* {}, (indexing) async* {
          yield AllLoaded(countries: countries, indexing: indexing);
        });
      },
    );
  }

  Stream<CountryState> _eitherMatchingLoadedOrErrorState(
    Either<Failure, List<Country>> failureOrCountries,
  ) async* {
    yield failureOrCountries.fold(
        (failure) => Error(message: _mapFailureToMessage(failure)),
        (countries) => MatchingLoaded(countries: countries));
  }

  Stream<CountryState> _eitherDetailSheetOrErrorState(
    Either<Failure, Country> failureOrCountry,
  ) async* {
    yield failureOrCountry.fold(
        (failure) => Error(message: _mapFailureToMessage(failure)),
        (country) => DetailSheet(country: country));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }
}
