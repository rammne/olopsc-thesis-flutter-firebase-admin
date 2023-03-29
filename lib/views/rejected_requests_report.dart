// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RejectedRequestsReport extends StatefulWidget {
  String userID;
  RejectedRequestsReport({
    required this.userID,
  });

  @override
  State<RejectedRequestsReport> createState() => _RejectedRequestsReportState();
}

class _RejectedRequestsReportState extends State<RejectedRequestsReport> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .collection('rejected_requests')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        final totalRejectedRequests = snapshot.data?.docs.length ?? 0;
        return Card(
          elevation: 6,
          color: Colors.grey[300],
          margin: const EdgeInsets.all(35),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Total Rejected Requests: $totalRejectedRequests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: ListView(
                    children: (snapshot.data?.docs ?? [])
                        .asMap()
                        .entries
                        .map((entry) {
                      final doc = entry.value;
                      final index = entry.key;
                      Timestamp timestamp = doc.get('date_time');
                      DateTime dateTime = timestamp.toDate();
                      String formattedDate =
                          DateFormat('yMMMd').format(dateTime);
                      String formattedTime = DateFormat('jm').format(dateTime);
                      return Column(
                        children: [
                          SizedBox(
                            height: 25,
                          ),
                          Card(
                            elevation: 6,
                            color: Colors.grey[400],
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${doc.get('item_name_rejected')}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${doc.get('item_quantity_rejected')}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${formattedDate} at ${formattedTime}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Divider()
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    ;
  }
}
