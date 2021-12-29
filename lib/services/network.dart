import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:roman/services/objects.dart';
import 'package:roman/widgets/snack_bar.dart';

import 'constants.dart';

class NetHandler {
  NetHandler(
    this.context,
  );

  final BuildContext context;

  Future<String?> _request({
    required String url,
    Map<String, String>? params,
  }) async {
    var response = await http.post(
      Uri.parse(apiUrl + url),
      body: params,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  }

  void _showAnswer(int status, String message) {
    StandartSnackBar.show(
      context,
      message,
      status == 0 ? SnackBarStatus.success() : SnackBarStatus.warning(),
    );
  }

  Future<String?> userAuth(
    String login,
    String pass,
  ) async {
    var address = 'user_auth.php';

    var data = await _request(url: address, params: {
      "login": login,
      "pass": pass,
    });

    if (data != null) {
      var answer = authAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.token;
      } else {
        _showAnswer(answer.error, answer.message);
      }
    } else {
      return null;
    }
  }

  Future<bool> checkToken(String token) async {
    var address = 'check_token.php';

    var data = await _request(url: address, params: {
      "token": token,
    });

    if (data != null) {
      var answer = tokenAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.status == 1;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<List<Company>> getCompanies(String token) async {
    var address = 'get_companies.php';

    var data = await _request(url: address, params: {
      "token": token,
    });

    if (data != null) {
      var answer = companiesAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.companies;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<Driver>> getDrivers(String token) async {
    var address = 'get_drivers.php';

    var data = await _request(url: address, params: {
      "token": token,
    });

    if (data != null) {
      var answer = driversAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.drivers;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<Company>> searchCompanies(String token, String text) async {
    var address = 'search_companies.php';

    var data = await _request(url: address, params: {
      "token": token,
      "text": text,
    });

    if (data != null) {
      var answer = companiesAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.companies;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<Company?> addCompany(
    String token,
    String name,
    String phone,
    String location,
    String note,
    String web,
  ) async {
    var address = 'add_company.php';

    var data = await _request(url: address, params: {
      "token": token,
      "name": name,
      "phone": phone,
      "location": location,
      "note": note,
      "web": web,
    });

    if (data != null) {
      var answer = companyAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.company;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<Driver?> addDriver(
    String token,
    String name,
    String phone,
    String mail,
    String pass,
    String count,
  ) async {
    var address = 'add_driver.php';

    var data = await _request(url: address, params: {
      "token": token,
      "name": name,
      "phone": phone,
      "mail": mail,
      "pass": pass,
      "count": count,
    });

    if (data != null) {
      var answer = driverAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.driver;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<Company?> editCompany(
    String token,
    String id,
    String name,
    String phone,
    String location,
    String note,
    String web,
  ) async {
    var address = 'edit_company.php';

    var data = await _request(url: address, params: {
      "token": token,
      "company_id": id,
      "name": name,
      "phone": phone,
      "location": location,
      "note": note,
      "web": web,
    });

    if (data != null) {
      var answer = companyAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.company;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<List<Location>> getDriverLocations(
    String token,
    String driverId,
  ) async {
    var address = 'get_driver_locations.php';

    var data = await _request(url: address, params: {
      "token": token,
      "driver_id": driverId,
    });

    if (data != null) {
      var answer = locationsAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.locations;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<Driver?> editDriver(
    String token,
    String id,
    String name,
    String phone,
    String mail,
    String pass,
    String status,
    String count,
  ) async {
    var address = 'edit_driver.php';

    var data = await _request(url: address, params: {
      "token": token,
      "driver_id": id,
      "name": name,
      "phone": phone,
      "mail": mail,
      "pass": pass,
      "status": status,
      "count": count,
    });

    if (data != null) {
      var answer = driverAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.driver;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<List<User>> getUsers(
    String token,
  ) async {
    var address = 'get_users.php';

    var data = await _request(url: address, params: {
      "token": token,
    });

    if (data != null) {
      var answer = usersAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.users;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<User?> addUser(
    String token,
    String name,
    String mail,
    String pass,
  ) async {
    var address = 'add_user.php';

    var data = await _request(url: address, params: {
      "token": token,
      "name": name,
      "mail": mail,
      "pass": pass,
    });

    if (data != null) {
      var answer = userAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.user;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<User?> editUser(
    String token,
    String userId,
    String name,
    String mail,
    String pass,
    String status,
  ) async {
    var address = 'edit_user.php';

    var data = await _request(url: address, params: {
      "token": token,
      "user_id": userId,
      "name": name,
      "mail": mail,
      "pass": pass,
      "status": status,
    });

    if (data != null) {
      var answer = userAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.user;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<Record?> addRecord(
    String token,
    String date,
    String company,
    String status,
    String note,
  ) async {
    var address = 'add_record.php';

    var data = await _request(url: address, params: {
      "token": token,
      "date": date,
      "company": company,
      "status": status,
      "note": note,
    });

    if (data != null) {
      var answer = recordAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.record;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<List<Record>> getRecords(
    String token,
  ) async {
    var address = 'get_records.php';

    var data = await _request(url: address, params: {
      "token": token,
    });

    if (data != null) {
      var answer = recordsAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.records;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<Result>> getPlaces(
    String token,
    String input,
  ) async {
    var address = 'get_places.php';

    var data = await _request(url: address, params: {
      "token": token,
      "input": input,
    });

    if (data != null) {
      var answer = placesAnswerFromJson(data);

      if (answer.status == "OK") {
        return answer.results;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<List<Driver>> searchDrivers(String token, String text) async {
    var address = 'search_drivers.php';

    var data = await _request(url: address, params: {
      "token": token,
      "text": text,
    });

    if (data != null) {
      var answer = driversAnswerFromJson(data);

      if (answer.error == 0) {
        return answer.drivers;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<bool> setDriver(
    String token,
    String recordId,
    String driver,
    String recordHistory,
  ) async {
    var address = 'set_driver.php';

    var data = await _request(url: address, params: {
      "token": token,
      "record_id": recordId,
      "driver": driver,
      "record_history": recordHistory,
    });

    if (data != null) {
      var answer = messageAnswerFromJson(data);
      _showAnswer(answer.error, answer.message);

      return answer.error == 0;
    } else {
      return false;
    }
  }

  Future<bool> editRecordNote(
    String token,
    String recordId,
    String note,
  ) async {
    var address = 'edit_record_note.php';

    var data = await _request(url: address, params: {
      "token": token,
      "record_id": recordId,
      "note": note,
    });

    if (data != null) {
      var answer = messageAnswerFromJson(data);
      _showAnswer(answer.error, answer.message);

      return answer.error == 0;
    } else {
      return false;
    }
  }

  Future<bool> cancelRecord(
    String token,
    String recordId,
    String history,
  ) async {
    var address = 'cancel_record.php';

    var data = await _request(url: address, params: {
      "token": token,
      "record_id": recordId,
      "record_history": history,
    });

    if (data != null) {
      var answer = messageAnswerFromJson(data);
      _showAnswer(answer.error, answer.message);

      return answer.error == 0;
    } else {
      return false;
    }
  }
}
