import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // late SharedPreferences _sharedPreferences;
  // LocalStorageService() {
  //   SharedPreferences.getInstance().then((value) {
  //     _sharedPreferences = value;
  //   });
  // }
  // LocalStorageService() {
  //   _initializeSharedPreferences();
  // }

  // SharedPreferences get getSharePrefrence => _sharedPreferences;

  // Future<void> _initializeSharedPreferences() async {
  //   _sharedPreferences = await SharedPreferences.getInstance();
  // }

  void saveCredentail(Credentail userCredentail) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setStringList(Keys.loginCredentails.name,
        [userCredentail.email, userCredentail.password]);
  }

  Future<Credentail?> getCredentail() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String>? data =
        sharedPreferences.getStringList(Keys.loginCredentails.name);
    return data != null && data.isNotEmpty
        ? Credentail(email: data[0], password: data[1])
        : null;
  }

  void removeCredentail() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(Keys.loginCredentails.name);
  }
}

class Credentail {
  String email;
  String password;
  Credentail({required this.email, required this.password});
}

enum Keys { loginCredentails }
