import 'package:aishshreya/data/model/TransactionDetail.dart';

/// id : 6
/// name : "Manicure"
/// service_date : "2023-02-28 13:30:00"
/// amount : 250
/// lead_id : 1
/// client_id : 1
/// e_id : 7
/// amount_paid : 0
/// created_at : "2023-02-13 15:33:19"
/// updated_at : ""
/// status : "Active"
/// emp_name : "Employee1"
/// emp_dialCode : "+91"
/// emp_phone : "9876543210"
/// emp_email : "Employee1"
/// emp_image : "http://192.168.1.24/aishshreya/public/Employee1"
/// client_name : "Tessa"
/// client_phone : "1212121212"
/// client_image : "http://192.168.1.24/aishshreya/public/uploads/leads/leads_1676274020img.jpg"

class ServiceDetail {
  ServiceDetail({
      this.id, 
      this.name, 
      this.serviceDate, 
      this.amount, 
      this.leadId, 
      this.clientId, 
      this.eId, 
      this.amountPaid, 
      this.createdAt, 
      this.updatedAt, 
      this.status, 
      this.description,
      this.empName,
      this.empDialCode, 
      this.empPhone, 
      this.empEmail, 
      this.empImage, 
      this.clientName, 
      this.clientPhone, 
      this.additionalServices = const [],
      this.clientImage,});

  ServiceDetail.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    serviceDate = json['service_date'];
    amount = json['amount'];
    leadId = json['lead_id'];
    clientId = json['client_id'];
    eId = json['e_id'];
    amountPaid = json['amount_paid'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
    description = json['description'];
    empName = json['emp_name'];
    empDialCode = json['emp_dialCode'];
    empPhone = json['emp_phone'];
    empEmail = json['emp_email'];
    empImage = json['emp_image'];
    clientName = json['client_name'];
    clientPhone = json['client_phone'];
    clientImage = json['client_image'];
    additionalServices = [];
    if(json['additional_services']!=null) {
      additionalServices = List.from((json['additional_services'] ?? []).map((e) => TransactionDetail.fromJson(e)));
    }
  }
  num? id;
  String? name;
  String? serviceDate;
  num? amount;
  num? leadId;
  num? clientId;
  num? eId;
  num? amountPaid;
  String? createdAt;
  String? updatedAt;
  String? status;
  String? description;
  String? empName;
  String? empDialCode;
  String? empPhone;
  String? empEmail;
  String? empImage;
  String? clientName;
  String? clientPhone;
  String? clientImage;
  late List<TransactionDetail> additionalServices;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['service_date'] = serviceDate;
    map['amount'] = amount;
    map['lead_id'] = leadId;
    map['client_id'] = clientId;
    map['e_id'] = eId;
    map['amount_paid'] = amountPaid;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['status'] = status;
    map['description'] = description;
    map['emp_name'] = empName;
    map['emp_dialCode'] = empDialCode;
    map['emp_phone'] = empPhone;
    map['emp_email'] = empEmail;
    map['emp_image'] = empImage;
    map['client_name'] = clientName;
    map['client_phone'] = clientPhone;
    map['client_image'] = clientImage;
    map['client_image'] = clientImage;
    map['additional_services'] = additionalServices;
    return map;
  }

}