class AppNotification {
  AppNotification({
      this.id, 
      this.eId, 
      this.title, 
      this.description, 
      this.image, 
      this.createdAt, 
      this.updatedAt, 
      this.status,});

  AppNotification.fromJson(dynamic json) {
    id = json['id'];
    eId = json['e_id'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
  }
  num? id;
  num? eId;
  String? title;
  String? description;
  String? image;
  String? createdAt;
  String? updatedAt;
  String? status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['e_id'] = eId;
    map['title'] = title;
    map['description'] = description;
    map['image'] = image;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['status'] = status;
    return map;
  }

}