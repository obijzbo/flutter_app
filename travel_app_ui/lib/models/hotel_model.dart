import 'package:travel_app_ui/models/services_model.dart';

class Hotel {
  String imageUrl;
  String name;
  String address;
  int price;
  List<Services> services;

  Hotel({
    required this.imageUrl,
    required this.name,
    required this.address,
    required this.price,
    required this.services,
  });
}

List<Services> services = [
  Services(
    imageUrl: 'assets/images/spa.jpg',
    name: 'Spa',
    rating: 5,
    price: 30,
  ),
  Services(
    imageUrl: 'assets/images/gym.jpg',
    name: 'Gym',
    rating: 4,
    price: 210,
  ),
  Services(
    imageUrl: 'assets/images/buffet.jpg',
    name: '',
    rating: 3,
    price: 125,
  ),
];

List<Hotel> hotels = [
  Hotel(
    imageUrl: 'assets/images/hotel0.jpg',
    name: 'La Reve',
    address: '404 Great St',
    price: 175,
    services: [],
  ),
  Hotel(
    imageUrl: 'assets/images/hotel1.jpg',
    name: 'Est Un Lavia',
    address: '404 Great St',
    price: 300,
    services: [],
  ),
  Hotel(
    imageUrl: 'assets/images/hotel2.jpg',
    name: 'Garlia',
    address: '404 Great St',
    price: 240,
    services: [],
  ),
];
