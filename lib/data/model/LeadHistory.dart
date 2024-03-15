class LeadHistory {
  LeadHistory({
      this.id, 
      this.leadId, 
      this.title,
      this.description,
      this.schedule,
      this.createdAt, 
      this.updatedAt, 
      this.status,});

  LeadHistory.fromJson(dynamic json) {
    id = json['id'];
    leadId = json['lead_id'];
    title = json['title'];
    description = json['description'];
    schedule = json['schedule'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
  }
  num? id;
  num? leadId;
  String? title;
  String? description;
  String? schedule;
  String? createdAt;
  String? updatedAt;
  String? status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['lead_id'] = leadId;
    map['title'] = title;
    map['description'] = description;
    map['schedule'] = schedule;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['status'] = status;
    return map;
  }

}