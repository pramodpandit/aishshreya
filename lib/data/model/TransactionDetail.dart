class TransactionDetail {
  TransactionDetail({
      this.id, 
      this.serviceId, 
      this.clientId, 
      this.amount, 
      this.description,
      this.type,
      this.createdAt, 
      this.serviceDate,
      this.updatedAt,
      this.status, 
      this.serviceName, 
      this.clientName, 
      this.clientPhone,
      this.empName,
      this.empDialCode,
      this.empPhone,
      this.empImage,
  });

  TransactionDetail.fromJson(dynamic json) {
    id = json['id'];
    serviceId = json['service_id'];
    clientId = json['client_id'];
    amount = json['amount'];
    description = json['description'];
    type = json['type'];
    createdAt = json['created_at'];
    serviceDate = json['service_date'];
    updatedAt = json['updated_at'];
    status = json['status'];
    serviceName = json['service_name'];
    clientName = json['client_name'];
    clientPhone = json['client_phone'];
    empName = json['emp_name'];
    empDialCode = json['emp_dial_code'];
    empPhone = json['emp_phone'];
    empImage = json['emp_image'];
  }
  num? id;
  num? serviceId;
  num? clientId;
  num? amount;
  String? type;
  String? description;
  String? createdAt;
  String? serviceDate;
  String? updatedAt;
  String? status;
  String? serviceName;
  String? clientName;
  String? clientPhone;
  String? empName;
  String? empDialCode;
  String? empPhone;
  String? empImage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['service_id'] = serviceId;
    map['client_id'] = clientId;
    map['amount'] = amount;
    map['description'] = description;
    map['type'] = type;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['service_date'] = serviceDate;
    map['status'] = status;
    map['service_name'] = serviceName;
    map['client_name'] = clientName;
    map['client_phone'] = clientPhone;
    map['emp_name'] = empName;
    map['emp_dial_code'] = empDialCode;
    map['emp_phone'] = empPhone;
    map['emp_image'] = empImage;
    return map;
  }

}