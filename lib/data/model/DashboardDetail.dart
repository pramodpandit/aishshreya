class DashboardDetail {
  DashboardDetail({
      this.totalEmployee, 
      this.totalClients, 
      this.totalLeads, 
      this.clientsLastWeek, 
      this.leadsLastWeek, 
      this.clientsLastMonth, 
      this.leadsLastMonth, 
      this.totalDue, 
      this.dueNextWeek, 
      this.dueNextMonth, 
      this.dueToday, 
      this.duePassed,});

  DashboardDetail.fromJson(dynamic json) {
    totalEmployee = json['total_employee'];
    totalClients = json['total_clients'];
    totalLeads = json['total_leads'];
    clientsLastWeek = json['clients_last_week'];
    leadsLastWeek = json['leads_last_week'];
    clientsLastMonth = json['clients_last_month'];
    leadsLastMonth = json['leads_last_month'];
    totalDue = json['total_due'];
    dueNextWeek = json['due_next_week'];
    dueNextMonth = json['due_next_month'];
    dueToday = json['due_today'];
    duePassed = json['due_passed'];
  }
  num? totalEmployee;
  num? totalClients;
  num? totalLeads;
  num? clientsLastWeek;
  num? leadsLastWeek;
  num? clientsLastMonth;
  num? leadsLastMonth;
  num? totalDue;
  num? dueNextWeek;
  num? dueNextMonth;
  num? dueToday;
  num? duePassed;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total_employee'] = totalEmployee;
    map['total_clients'] = totalClients;
    map['total_leads'] = totalLeads;
    map['clients_last_week'] = clientsLastWeek;
    map['leads_last_week'] = leadsLastWeek;
    map['clients_last_month'] = clientsLastMonth;
    map['leads_last_month'] = leadsLastMonth;
    map['total_due'] = totalDue;
    map['due_next_week'] = dueNextWeek;
    map['due_next_month'] = dueNextMonth;
    map['due_today'] = dueToday;
    map['due_passed'] = duePassed;
    return map;
  }

}