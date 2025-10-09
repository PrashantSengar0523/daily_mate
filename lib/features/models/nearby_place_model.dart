class NearbyPlaceModel {
  final String type;
  final int id;
  final double lat;
  final double lon;
  final Tags tags;

  NearbyPlaceModel({
    required this.type,
    required this.id,
    required this.lat,
    required this.lon,
    required this.tags,
  });

  factory NearbyPlaceModel.fromJson(Map<String, dynamic> json) {
    return NearbyPlaceModel(
      type: json['type'] ?? 'node',
      id: json['id'] ?? 0,
      lat: (json['lat'] ?? 0.0).toDouble(),
      lon: (json['lon'] ?? 0.0).toDouble(),
      tags: Tags.fromJson(json['tags'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'lat': lat,
      'lon': lon,
      'tags': tags.toJson(),
    };
  }
}

class Tags {
  final String? district;
  final String? fullAddress;
  final String? postcode;
  final String? state;
  final String? amenity;
  final String? email;
  final String? name;
  final String? operatorType;
  final String? source;
  final String? website;

  Tags({
    this.district,
    this.fullAddress,
    this.postcode,
    this.state,
    this.amenity,
    this.email,
    this.name,
    this.operatorType,
    this.source,
    this.website,
  });

  factory Tags.fromJson(Map<String, dynamic> json) {
    return Tags(
      district: json['addr:district'],
      fullAddress: json['addr:full'],
      postcode: json['addr:postcode'],
      state: json['addr:state'],
      amenity: json['amenity'],
      email: json['email'],
      name: json['name'],
      operatorType: json['operator:type'],
      source: json['source'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addr:district': district,
      'addr:full': fullAddress,
      'addr:postcode': postcode,
      'addr:state': state,
      'amenity': amenity,
      'email': email,
      'name': name,
      'operator:type': operatorType,
      'source': source,
      'website': website,
    };
  }
}
