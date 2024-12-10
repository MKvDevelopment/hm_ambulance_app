class AmbulanceModel {
  String bookingId;
  String name;
  String contactNumber;
  String hostal;
  String roomNo;
  String pickupLocation;
  String description;
  String destination;
  String driverId;
  String confirmStatus;
  String? userId;
  String bookingTime;

  AmbulanceModel({
    required this.bookingId,
    required this.userId,
    required this.name,
    required this.driverId,
    required this.confirmStatus,
    required this.contactNumber,
    required this.hostal,
    required this.roomNo,
    required this.destination,
    required this.pickupLocation,
    required this.description,
    required this.bookingTime,
  });

  // Convert object to map for Firestore submission
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bookingId': bookingId,
      'userId': userId,
      'contactNumber': contactNumber,
      'confirmStatus': confirmStatus,
      'hostal': hostal,
      'roomNo': roomNo,
      'driverId': driverId,
      'destination': destination,
      'pickupLocation': pickupLocation,
      'description': description,
      'bookingTime': bookingTime, // storing the formatted time
    };
  }

  // Convert Firestore map back to object
  factory AmbulanceModel.fromMap(Map<String, dynamic> map) {
    return AmbulanceModel(
      name: map['name'],
      bookingId: map['bookingId'],
      userId: map['userId'],
      driverId: map['driverId'],
      destination: map['destination'],
      contactNumber: map['contactNumber'],
      hostal: map['hostal'],
      confirmStatus: map['confirmStatus'],
      roomNo: map['roomNo'],
      pickupLocation: map['pickupLocation'],
      description: map['description'],
      bookingTime: map['bookingTime'],
    );
  }
}
