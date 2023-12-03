import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<UserCredential?> signInWithGoogle(WidgetRef ref) async {
  ref.read(authLoader.notifier).state = true;

  try {
    // Trigger Google Sign In
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      // User canceled Google sign-in
      changeAuthLoaderState(ref, false);
      return null;
    }

    // Obtain GoogleSignInAuthentication and sign in with Firebase
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential googleCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await _auth.signInWithCredential(googleCredential);

    if (userCredential.user != null) {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid);

      // Check if the user has signed up with Google before
      DocumentSnapshot userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        // User has signed up with Google before, retrieve additional data
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        String name = userData['name'];
        String phoneNo = userData['phoneNo'];

        String uid = userCredential.user!.uid;
        String email = userCredential.user!.email!;

        ref.read(credential.notifier).state = AppUser(
          name: name,
          uid: uid,
          phoneNo: phoneNo,
          email: email,
        );
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({'name': "", "phoneNo": "", "conversation": []});
        DocumentSnapshot userSnapshot = await userRef.get();
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        String name = userData['name'];
        String phoneNo = userData['phoneNo'];

        String uid = userCredential.user!.uid;
        String email = userCredential.user!.email!;

        ref.read(credential.notifier).state = AppUser(
          name: name,
          uid: uid,
          phoneNo: phoneNo,
          email: email,
        );
      }
    }

    changeAuthLoaderState(ref, false);
    return userCredential;
  } catch (e) {
    // Handle errors here
    print('Error during Google sign-in: $e');
    changeAuthLoaderState(ref, false);
    return null;
  }
}

Future<UserCredential?> registerWithEmailPassword(String email, String password,
    String name, String phoneNo, WidgetRef ref) async {
  ref.read(authLoader.notifier).state = true;
  try {
    // Create a new user with email and password
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({'name': name, "phoneNo": phoneNo, "conversation": []});

    changeAuthLoaderState(ref, false);
    return userCredential;
  } catch (e) {
    // Handle errors here
    changeAuthLoaderState(ref, false);

    return null;
  }
}

Future<UserCredential?> loginWithEmailPassword(
    String email, String password, WidgetRef ref) async {
  try {
    changeAuthLoaderState(ref, true);
    //login with email and password
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    if (userCredential.user != null) {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid);

      // Fetch the data for the document
      DocumentSnapshot userSnapshot = await userRef.get();
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

      String name = userData['name'];
      String phoneNo = userData['phoneNo'];

      String uid = userCredential.user!.uid;
      String email = userCredential.user!.email!;

      ref.read(credential.notifier).state = AppUser(
        name: name,
        uid: uid,
        phoneNo: phoneNo,
        email: email,
      );
    }
    changeAuthLoaderState(ref, false);
    return userCredential;
  } catch (e) {
    // Handle errors here
    changeAuthLoaderState(ref, false);
    return null;
  }
}

void changeAuthLoaderState(WidgetRef ref, bool state) {
  ref.read(authLoader.notifier).state = state;
}

final credential = StateProvider<AppUser?>((ref) {
  return null;
});

final authLoader = StateProvider<bool>(
  (ref) {
    return false;
  },
);

class AppUser {
  String name;
  String uid;
  String phoneNo;
  String email;
  AppUser({
    required this.name,
    required this.uid,
    required this.phoneNo,
    required this.email,
  });
}

class Validity {
  static bool isEmailValid(String email) {
    // regular expression pattern for a valid email address
    const pattern = r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$';

    final regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  static bool isPasswordValid(String password) {
    return password.length > 7;
  }

  static bool isconfirmPasswordValid(String password, String confirmpass) {
    return password == confirmpass;
  }

  static bool isPhoneNoValid(String phoneNo) {
    return phoneNo.length == 11;
  }

  static List<String> isValidLoginForm(String email, String password) {
    List<String> missingElements = [];
    if (!isEmailValid(email)) {
      missingElements.add("Invalid email");
    }
    if (!isPasswordValid(password)) {
      missingElements.add("Password is less then 8 character");
    }
    return missingElements;
  }

  static List<String> isValidSignupForm(String email, String password,
      String phoneNo, String confirmpass, String name) {
    List<String> missingElements = [];
    if (!isEmailValid(email)) {
      missingElements.add("Invalid email");
    }
    if (!(name.length > 2)) {
      missingElements.add("name is not valid");
    }
    if (!isPhoneNoValid(phoneNo)) {
      missingElements.add("Invalid phone number");
    }
    if (!isPasswordValid(password)) {
      missingElements.add("Password is less then 8 character");
    }
    if (!isconfirmPasswordValid(password, confirmpass)) {
      missingElements.add("Both password don't match ");
    }

    return missingElements;
  }
}
