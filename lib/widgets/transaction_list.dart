
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'transaction_card.dart' show TransactionCard;

class TransectionList extends StatelessWidget {
  TransectionList(
      {super.key,
      required this.category,
      required this.type,
      required this.monthYear});

  final userId = FirebaseAuth.instance.currentUser!.uid;
  

  final String category;
  final String type;
  final String monthYear;

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection("transactions")
        .orderBy('timestamp', descending: true)
        .where('monthyear', isEqualTo: monthYear)
        .where('type', isEqualTo: type);

    if (category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return FutureBuilder<QuerySnapshot>(
        future: query.limit(500).get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }
          var data = snapshot.data!.docs;
          var total = 0;
          for (var i in data) {
            total += i['amount'] as int;
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var cardData = data[index];
                      return TransactionCard(
                        data: cardData,
                      );
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Total ${type}"), Text("₹${total}")],
                ),
              )
            ],
          );
        });
  }
}
