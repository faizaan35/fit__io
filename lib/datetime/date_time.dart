//return todays date in yyyymmdd format
String todaysDateFormatted() {
  //get today date time

  var dateTimeObject = DateTime.now();
  //convert year into yyyy

  String year = dateTimeObject.year.toString();

  //convert month into mm
  String month = dateTimeObject.month.toString();

  if (month.length == 1) {
    month = '0$month';
  }

  // convert day into dd

  String day = dateTimeObject.day.toString();
  if (day.length == 1) {
    day = '0$day';
  }

  //combining all into the yyyymmdd\
  String yyyymmdd = year + month + day;

  return yyyymmdd;
}

//convert string yyyymmdd in date time object
DateTime createDateTimeObject(String yyyymmdd) {
  int yyyy = int.parse(yyyymmdd.substring(0, 4));
  int mm = int.parse(yyyymmdd.substring(4, 6));
  int dd = int.parse(yyyymmdd.substring(6, 8));

  DateTime dateTimeObject = DateTime(yyyy, mm, dd);

  return dateTimeObject;
}

//convert dateTime object into string yyyymmdd
String createDateTimeToString(DateTime dateTime) {
  String year = dateTime.year.toString();

  //convert month into mm
  String month = dateTime.month.toString();

  if (month.length == 1) {
    month = '0$month';
  }

  // convert day into dd

  String day = dateTime.day.toString();
  if (day.length == 1) {
    day = '0$day';
  }

  //combining all into the yyyymmdd\
  String yyyymmdd = year + month + day;

  return yyyymmdd;
}
