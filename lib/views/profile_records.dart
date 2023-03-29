// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:admin/views/rejected_requests_report.dart';
import 'package:admin/views/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'accepted_requests_report.dart';

class ProfileReport extends StatefulWidget {
  String userID;
  ProfileReport({required this.userID});

  @override
  State<ProfileReport> createState() => _ProfileReportState();
}

class _ProfileReportState extends State<ProfileReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color(Colors.black.value),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Row(
        children: [
          Expanded(child: UserProfile(userID: widget.userID)),
          Expanded(
            child: Column(
              children: [
                Expanded(child: AcceptedRequestsReport(userID: widget.userID)),
                Expanded(child: RejectedRequestsReport(userID: widget.userID)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
