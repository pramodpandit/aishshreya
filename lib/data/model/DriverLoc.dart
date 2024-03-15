class DriverLoc {
  DriverLoc({
      this.id, 
      this.lat, 
      this.lon, 
      this.createdAt, 
      this.updatedAt, 
      this.status, 
      this.distance,});

  DriverLoc.fromJson(dynamic json) {
    id = json['id'];
    lat = json['lat'];
    lon = json['lon'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
    distance = json['distance'];
  }
  num? id;
  String? lat;
  String? lon;
  String? createdAt;
  String? updatedAt;
  String? status;
  num? distance;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['lat'] = lat;
    map['lon'] = lon;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['status'] = status;
    map['distance'] = distance;
    return map;
  }

}