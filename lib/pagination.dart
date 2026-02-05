// import 'package:flutter/material.dart';
// import 'package:number_pagination/number_pagination.dart';

// class PaginationNumber extends StatefulWidget {
//   const PaginationNumber({super.key});

//   @override
//   State<PaginationNumber> createState() => _PaginationNumberState();
// }

// class _PaginationNumberState extends State<PaginationNumber> {
//   var currentPage = 0;
//   var numberOfPage = 10;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Flexible(
//             child: Container(
//               alignment: Alignment.center,
//               color: Colors.amber,
//               height: 100,
//               child: Text("Page Number $currentPage"),
//             ),
//           ),

//           NumberPagination(
//             onPageChanged: (index) {
//               setState(() {
//                 currentPage = index;
//               });
//             },
//             totalPages: numberOfPage,
//             currentPage: currentPage,
//             visiblePagesCount: 10,
//           ),
//         ],
//       ),
//     );
//   }
// }


