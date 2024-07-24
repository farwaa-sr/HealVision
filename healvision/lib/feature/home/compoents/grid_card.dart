// import 'package:flutter/material.dart';

// import '../../../../../utilis/constants/colors.dart';
// import '../../../../../utilis/helpers/helper_function.dart';



// class GridCard extends StatelessWidget {
//   const GridCard(
//       {super.key,
//       required this.imageurl,
//       required this.texttitle,
//       required this.onpressed});
//   final String imageurl, texttitle;
//   final VoidCallback onpressed;
//   @override
//   Widget build(BuildContext context) {
//     final drak =THelperFunctions.isDarkMode(context);
//     return GestureDetector(
//       onTap: onpressed,
//       child: Container(
//         width: MediaQuery.of(context).size.width / 2.6,
//         height: MediaQuery.of(context).size.height / 5,
//         padding: const EdgeInsets.all(10),
//         margin: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: WColors.primary,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: drak ? []: const [
//             BoxShadow(
//               color: Colors.grey,
//               blurRadius: 5,
//               spreadRadius: 1,
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Image.asset(
//                 imageurl,
//                 height: 50,
//                 width: 50,
//                 fit: BoxFit.cover,
//                 color: WColors.white,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Align(
//               alignment: Alignment.center,
//               child: Text(
//                   textAlign: TextAlign.center,
//                   texttitle,
//                   style: Theme.of(context).textTheme.titleMedium!.copyWith(color: WColors.white)),
//             ),
//             const SizedBox(height: 4),
//           ],
//         ),
//       ),
//     );
//   }
// }
