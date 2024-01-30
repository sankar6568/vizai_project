class DataHolder {
  static int data = 80;
  static List<dynamic> users = [];
  static int batteryValue =
      int.tryParse(users.isNotEmpty ? users[0]['BatteryVoltage'] : '') ??
          0; // Change the type to int
}
