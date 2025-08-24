// import 'package:flutter/material.dart';
//
// class Login extends StatefulWidget {
//   const Login({super.key});
//
//   @override
//   State<Login> createState() => _LoginState();
// }
//
// class _LoginState extends State<Login> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             GestureDetector(
//               onTap: () {
//                 signInWithGoogle(context);
//               },
//               child: Container(
//                 width: double.maxFinite,
//                 height: 55,
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(color: Colors.black)),
//                 child: Center(
//                     child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Image(
//                       image: AssetImage('assets/icon/google_icon.png'),
//                       fit: BoxFit.cover,
//                       height: 20,
//                       width: 20,
//                     ),
//                     const SizedBox(
//                       width: 10,
//                     ),
//                     Text("Google sign in", style: TextStyle()),
//                   ],
//                 )),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
