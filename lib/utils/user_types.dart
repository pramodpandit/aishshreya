class UserType {
  static const String SUPER_ADMIN = "SUPER_ADMIN";
  static const String ADMIN = "ADMIN";
  static const String HALL_COORDINATE_MANAGER = "HALL_COORDINATE_MANAGER";
  static const String EVENT_MANAGER = "EVENT_MANAGER";
  static const String SPEAKER = "SPEAKER";
  static const String DELEGATE = "DELEGATE";
  static const String CHAIRPERSON = "CHAIRPERSON";
  static const String EXHIBITOR = "EXHIBITOR";

  static toNormalString(String type) {
    switch(type) {
      case SUPER_ADMIN: return "Super Admin";
      case ADMIN: return "Admin";
      case HALL_COORDINATE_MANAGER: return "Hall Coordinate Manager";
      case EVENT_MANAGER: return "Event Manager";
      case SPEAKER: return "Speaker";
      case DELEGATE: return "Delegate";
      case CHAIRPERSON: return "Chairperson";
      case EXHIBITOR: return "Exhibitor";
      default: return "";
    }
  }

  static bool showProgram(String role) {
    if(role!=UserType.EXHIBITOR && role!=UserType.SUPER_ADMIN && role!=UserType.ADMIN) {
      return true;
    } else {
      return false;
    }
  }
}