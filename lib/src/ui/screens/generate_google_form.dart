import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class GenerateGoogleForm extends StatefulWidget {
  const GenerateGoogleForm({super.key});

  @override
  State<GenerateGoogleForm> createState() => _GenerateGoogleFormState();
}

class _GenerateGoogleFormState extends State<GenerateGoogleForm> {
  TextEditingController topicController = TextEditingController();
  TextEditingController questionsController = TextEditingController();
  String formUrl = '';

  // String scriptUrl =
  //     'https://script.google.com/macros/s/AKfycbwpVJlqIGEChMJyiUT8vvb31lxW0cUrSN94bTeG6nBpoPRIGEAOm4W1r-zxpycyv2GC1A/exec';
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: /*dotenv.env[
        'CLIENT_ID']*/
        '945217121097-ka2872p8llpoo6gpjlr48305hkkpevc1.apps.googleusercontent.com',
    scopes: [
      'https://www.googleapis.com/auth/forms',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );
  List questionsGenerated = [];
  bool isLoading = false;
  String loadingText = '';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(kIsWeb ? "assets/bg.jpg" : "assets/bg_mobile.jpg"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.7),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    topText(),
                    const SizedBox(height: 30),
                    centreBox(size, context),
                    const SizedBox(height: 30),
                    bottomText(),
                    const SizedBox(height: 80),
                    disclaimer(),
                  ],
                ),
              ),
            ),

            // --- Loading Overlay ---
            if (isLoading)
              Container(
                color: Colors.transparent,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        loadingText,
                        style: GoogleFonts.theGirlNextDoor(),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Text disclaimer() {
    return Text(
      '''🔐 No data is saved – All forms are generated privately and securely.\n💡 Perfect for quizzes, feedback forms, event registrations, and more.''',
      textAlign: TextAlign.center,
      style: GoogleFonts.openSans(
        color: Colors.white,
        fontWeight: FontWeight.w100,
        fontSize: 11,
      ),
    );
  }

  Column bottomText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How it works:',
          textAlign: TextAlign.left,
          style: GoogleFonts.theGirlNextDoor(
              fontWeight: FontWeight.bold, fontSize: 50, color: Colors.white),
        ),
        // const SizedBox(height: 8),
        Text(
          '- Describe your form – Tell us the topic and what you need.',
          textAlign: TextAlign.left,
          style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
        ),
        Text(
          '- AI generates questions – Instantly get multiple-choice questions tailored to your input.',
          textAlign: TextAlign.left,
          style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
        ),
        Text(
          '- Auto-create a Google Form – Linked directly to your Google account.',
          textAlign: TextAlign.left,
          style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }

  Column topText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to Formify',
          textAlign: TextAlign.left,
          style: GoogleFonts.theGirlNextDoor(
              fontWeight: FontWeight.bold, fontSize: 60, color: Colors.white),
        ),
        Text(
          'Effortlessly generate professional Google Forms in seconds – powered by AI.',
          textAlign: TextAlign.left,
          style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Tired of writing questions manually? Whether you\'re a teacher, event organizer, or business owner, Formify makes it easy.',
          textAlign: TextAlign.left,
          style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }

  Container centreBox(Size size, BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: size.width / 10),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildInputField(
                controller: topicController,
                label: "Describe your topic",
                icon: Icons.topic_outlined,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: questionsController,
                label: "Number of questions (max 10)",
                icon: Icons.format_list_numbered,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    elevation: 4,
                  ),
                  onPressed: () async {
                    if (int.parse(questionsController.text) <= 10) {
                      setState(() {
                        formUrl = '';
                      });
                      // await generateFormQuestions(topicController.text,
                      //         int.parse(questionsController.text))
                      //     .then((value) async {
                      //   if (value != null) {
                      await generateForm();
                      //   }
                      // });
                    }
                  },
                  child: const Text(
                    "✨ Generate",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (formUrl.isNotEmpty) _buildLinkCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.teal),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Form link card
  Widget _buildLinkCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Form is Ready 🎉",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => launchUrl(Uri.parse(formUrl)),
              child: Text(
                formUrl,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: formUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Copied to clipboard ✅")),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text("Copy"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // const SizedBox(width: 12),
                // ElevatedButton.icon(
                //   onPressed: () {
                //     // TODO: implement share
                //   },
                //   icon: const Icon(Icons.share, size: 18),
                //   label: const Text("Share"),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.teal.shade50,
                //     foregroundColor: Colors.teal,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //   ),
                // ),
              ],
            )
          ],
        ),
      ),
    );
  }

  generateForm() async {
    try {
      setLoading(true, 'Generating Form');
      // await _googleSignIn.signOut();
      GoogleSignInAccount? googleUser = _googleSignIn.currentUser;

      if (googleUser == null) {
        googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          // User cancelled sign-in
          return null;
        }
      }
      // cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
// log('$accessToken');
      final response = await http.post(
        Uri.parse(
            'https://personal-projects-backend.onrender.com/formify/createForm'
            // 'http://192.168.0.196:3000/formify/createForm'
            ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accessToken': accessToken,
          'topic': topicController.text,
          'questions': int.parse(questionsController.text)
        }),
      );

      log('${response.body}');
      setState(() {
        formUrl = jsonDecode(response.body)['response']; /*response.body*/
      });
    } catch (e) {
      log('$e');
      Fluttertoast.showToast(msg: 'Error');
    }
    setLoading(false, '');
  }

//   Future<List<Map<String, dynamic>>?> generateFormQuestions(
//       String topic, int questions) async {
//     try {
//       setLoading(true, 'Generating Questions');
//       final openAiApiKey = dotenv.env['GPT_API_KEY'];
//       // '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';
//       final prompt = '''
// Generate $questions multiple-choice quiz questions on the topic "$topic".
// Each question should have:
// - A question string
// - 3-4 options
// - A correct answer
//
// IMPORTANT:
// - If the topic contains any 18+ content, violence, hate speech, religious, political, or otherwise sensitive/offensive material,
//   DO NOT generate any questions.
// - Instead, respond strictly with this JSON:
// [{
//   "warning": "This topic contains restricted or inappropriate content and cannot be used to generate questions."
// }]
//
// Otherwise, respond strictly in this format:
// [
//   {
//     "question": "What does AI stand for?",
//     "options": ["Artificial Ice", "Artificial Intelligence", "Auto Industry"],
//     "answer": "Artificial Intelligence"
//   },
//   ...
// ]
// ''';
//
//       final url = Uri.parse('https://api.openai.com/v1/chat/completions');
//
//       final response = await http.post(
//         url,
//         headers: {
//           'Authorization': 'Bearer $openAiApiKey',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           "model": "gpt-3.5-turbo",
//           'messages': [
//             {'role': 'user', 'content': prompt}
//           ],
//           'temperature': 0.7,
//         }),
//       );
//       // log('${response.body}');
//       if (response.statusCode == 200) {
//         final rawContent =
//             jsonDecode(response.body)['choices'][0]['message']['content'];
//         List content = jsonDecode(rawContent);
//         log('$content');
//         if (content.first.containsKey('warning')) {
//           Fluttertoast.showToast(msg: '${content.first['warning']}');
//
//           throw Exception('${content.first['warning']}');
//         } else {
//           questionsGenerated = content;
//           setLoading(false, '');
//           return questionsGenerated.cast<Map<String, dynamic>>();
//         }
//       } else {
//         throw Exception('Failed to generate questions: ${response.body}');
//       }
//     } catch (e, st) {
//       log('$e');
//       log('$st');
//       setLoading(false, '');
//       return null;
//     }
//   }

  setLoading(bool value1, String value2) {
    setState(() {
      isLoading = value1;
      loadingText = value2;
    });
  }
}
