import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imagetoframe/controller/authcontroller.dart';

Future<String> uploadVideoToFirebaseStorage(String localVideoPath) async {
  final uniqueFileName =
      '${DateTime.now().millisecondsSinceEpoch}_${UniqueKey().toString()}.mp4';

// Create a reference to the Firebase Storage location with the unique filename
  final storageRef =
      FirebaseStorage.instance.ref().child('videos/$uniqueFileName');
  final uploadTask = storageRef.putFile(File(localVideoPath));

  await uploadTask.whenComplete(() => {print("uploaded file successfully")});

  final downloadURL = await storageRef.getDownloadURL();
  return downloadURL;
}

Future<void> getConversations(WidgetRef ref) async {
  // Get a reference to the document for the user with the given UID
  DocumentReference userRef = FirebaseFirestore.instance
      .collection('users')
      .doc(ref.watch(credential)!.uid);

  // Fetch the data for the document
  DocumentSnapshot userSnapshot = await userRef.get();
  Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

  List<Conversation> conversations = (userData['conversation'] as List<dynamic>)
      .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
      .toList();

  ref.read(conversationData.notifier).state = conversations;
}

Future<void> addConversation(
    WidgetRef ref, String videoPath, String answer) async {
  String uploadVideoPath = await uploadVideoToFirebaseStorage(videoPath);

  DocumentReference userRef = FirebaseFirestore.instance
      .collection('users')
      .doc(ref.watch(credential)!.uid);

  Conversation newConversation = Conversation(
    video: uploadVideoPath,
    answer:
        'go to downloads and in symbolRecog check the images for this video lorepsumsondoifnosinofinsoeinfunnueninfinsinfisnifnsnfsbdfhjsbdfhsbfhsbfhsbfhsbhfbshdfbhbsfb',
  );

  await userRef.update({
    'conversation': FieldValue.arrayUnion([newConversation.toJson()]),
  });

  ref.read(conversationData.notifier).state = [
    ...ref.watch(conversationData),
    newConversation
  ];

  changeLoaderState(ref, false);
}

class Conversation {
  String video;
  String answer;
  Conversation({required this.video, required this.answer});

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      video: json['video'] as String,
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video': video,
      'answer': answer,
    };
  }
}

void changeLoaderState(WidgetRef ref, bool state) {
  ref.read(conversationLoader.notifier).state = state;
}

final conversationLoader = StateProvider<bool>((ref) {
  return false;
});

final conversationData = StateProvider<List<Conversation>>((ref) {
  return [];
});
