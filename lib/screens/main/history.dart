import 'package:aplikasi/globals/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../globals/history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Log>> _logs;

  @override
  void initState() {
    super.initState();
    _logs = dbn.history();
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder(
        future: _logs,
        builder: (BuildContext context, AsyncSnapshot<List<Log>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Item(
                      id: snapshot.data![index].id,
                      title: snapshot.data![index].title,
                      message: snapshot.data![index].message,
                      type: snapshot.data![index].type,
                      date: snapshot.data![index].date,
                    );
                  }
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
      ),
    );
  }
}

class Item extends StatelessWidget {
  const Item({Key? key, required this.id, required this.title, required this.message, required this.type, required this.date}) : super(key: key);
  final int id;
  final String title;
  final String message;
  final int type;
  final int date;

  String convertTimeStamp(int timestamp) {
    final format = DateFormat('"MM/dd hh:mm:ss aaa"');
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final time = format.format(date);
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(message),
      trailing: Text(convertTimeStamp(date)),
      );
  }
}
