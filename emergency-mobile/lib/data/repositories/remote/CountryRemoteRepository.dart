
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency/data/repositories/CountryDataSource.dart';
import 'package:emergency/domain/entities/Country.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CountryRemoteRepository implements CountryRemoteDataSource {
  
  Firestore firestore;
  FirebaseMessaging fcm;
  CountryRemoteRepository(this.firestore, this.fcm);

  @override
  Future<List<Country>> getCountries() async {
    QuerySnapshot querySnapshot = await firestore.collection("countries").getDocuments();
    var countries = querySnapshot.documents.map((f) => Country(f.data["name"])).toList();
    return countries;
  }

  @override
  Future<List<Country>> getCountriesBy(String userId) async {
    // TODO: filtering
    QuerySnapshot querySnapshot = await firestore.collection("countries").getDocuments();
    var countries = querySnapshot.documents.map((f) => Country(f.data["name"])).toList();
    return countries;
  }

  @override
  void updateSubscription(Country country, bool subscribe) {
    if (subscribe) {
      fcm.subscribeToTopic(country.name);
    } else {
      fcm.unsubscribeFromTopic(country.name);
    }
  }
}