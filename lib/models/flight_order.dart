import 'package:airline/models/user.dart';

class FlightOrder {
  final int flightOrderId;
  final String tossOrderId;
  final int quantity;
  final String orderStatus;
  final int flightScheduleId;
  final String departureAirport;
  final String arrivalAirport;
  final String airlineName;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String travelDate;
  final double totalPrice;
  final String bookingDate;
  final String flightId;
  final User user;

  FlightOrder({
    required this.travelDate,
    required this.totalPrice,
    required this.bookingDate,
    required this.user,
    required this.flightOrderId,
    required this.tossOrderId,
    required this.quantity,
    required this.orderStatus,
    required this.flightScheduleId,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.airlineName,
    required this.departureTime,
    required this.arrivalTime,
    required this.flightId,

});

  factory FlightOrder.fromJson(Map<String,dynamic> json){
    return FlightOrder(
      travelDate: json['travelDate'] ?? '',  // 기본값 처리
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),  // 타입 변환
      bookingDate: json['bookingDate'] ?? '',
      user: User.fromJson(json['user'] ?? {}),  // null 안전성 처리
      flightOrderId: json['flightOrderId'] ?? 0,
      tossOrderId: json['tossOrderId'] ?? '',
      quantity: json['quantity'] ?? 0,
      orderStatus: json['orderStatus'] ?? 'UNKNOWN',
      flightScheduleId: int.tryParse(json['flightScheduleId'].toString()) ?? 0,  // 문자열로 올 경우 대비
      departureAirport: json['departureAirport'] ?? '',
      arrivalAirport: json['arrivalAirport'] ?? '',
      airlineName: json['airlineName'] ?? '',
      flightId: json['flightId'] ?? '',
      departureTime: DateTime.tryParse(json['departureTime']) ?? DateTime.now(),  // DateTime 파싱
      arrivalTime: DateTime.tryParse(json['arrivalTime']) ?? DateTime.now(),


    );
  }
}