import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:musik_streaming_app/firebase_options.dart';
import 'package:musik_streaming_app/screens/login_screen.dart';
import 'package:musik_streaming_app/screens/songs_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

// const String apiBaseUrl = "https://api.sws.speechify.com";
// const String apiKey = "4Kk9pLeJufgEPcK5Nu-c_ipTNhdy_VDssXROx3CN-Js=";
// const String voiceId = "george";

// Future<void> getAudio(String text) async {
//   final Uri url = Uri.parse('$apiBaseUrl/v1/audio/speech');

//   // Prepare the body data for the request
//   final body = jsonEncode({
//     "input": "<speak>$text</speak>",
//     "voice_id": voiceId,
//     "audio_format": "mp3",
//   });

//   final headers = {
//     'Authorization': 'Bearer $apiKey',
//     'Content-Type': 'application/json',
//   };

//   // Send the POST request
//   final response = await http.post(url, headers: headers, body: body);

//   if (response.statusCode != 200) {
//     throw Exception(
//         'Failed to load audio: ${response.statusCode} ${response.body}');
//   }

//   // Decode the audio data from base64
//   final responseData = jsonDecode(response.body);
//   final audioData = base64Decode(responseData['audio_data']);

//   // Get the directory to store the audio file
//   final directory = await getApplicationDocumentsDirectory();
//   final filePath = '${directory.path}/speech.mp3';

//   // Save the audio file to the device
//   final file = File(filePath);
//   await file.writeAsBytes(audioData);

//   print('Audio saved at $filePath');
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (Platform.isAndroid) {
    try {
      final permissionStatus = await Permission.storage.request();
    } catch (e) {
      print(e);
    }
  }
  

  // try {
  //   await getAudio("Hello, world!");
  // } catch (e) {
  //   print('Error: $e');
  // }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SigninScreen(),
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 0, 168, 137),
        hintColor: Color.fromARGB(255, 0, 168, 137),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color.fromARGB(255, 0, 168, 137),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
