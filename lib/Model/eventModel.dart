
class LocationPoint {
  String? type;
  List<double>? coordinates;

  LocationPoint({
    this.type,
    this.coordinates,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}

class EventModel {
  int? id;
  String? name;
  String? description;
  DateTime? start_date; // $date
  DateTime? end_date; // $date
  String? location_name;
  String? address;
  double? latitude;
  double? longitude;
  LocationPoint? location_point; // Nested object
  String? organizer;
  String? event_url; // $uri
  String? poster_image_url; // $uri
  DateTime? created_at; // $date-time
  DateTime? updated_at; // $date-time

  EventModel({
    this.id,
    this.name,
    this.description,
    this.start_date,
    this.end_date,
    this.location_name,
    this.address,
    this.latitude,
    this.longitude,
    this.location_point,
    this.organizer,
    this.event_url,
    this.poster_image_url,
    this.created_at,
    this.updated_at,
  });

  // Factory constructor to create an EventModel instance from a JSON Map
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
     
      start_date: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String)
          : null,
      end_date: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
      location_name: json['location_name'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      location_point: json['location_point'] != null
          ? LocationPoint.fromJson(json['location_point'] as Map<String, dynamic>)
          : null,
      organizer: json['organizer'] as String?,
      event_url: json['event_url'] as String?,
      poster_image_url: json['poster_image_url'] as String?,
      created_at: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updated_at: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  // Method to convert an EventModel instance to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    
      'start_date': start_date?.toIso8601String().split('T')[0], 
      'end_date': end_date?.toIso8601String().split('T')[0],    
      'location_name': location_name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'location_point': location_point?.toJson(),
      'organizer': organizer,
      'event_url': event_url,
      'poster_image_url': poster_image_url,
      'created_at': created_at?.toIso8601String(), // Convert DateTime to ISO 8601 string
      'updated_at': updated_at?.toIso8601String(), // Convert DateTime to ISO 8601 string
    };
  }
}