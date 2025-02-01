import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class box extends StatefulWidget {
  final int id;
  const box({super.key, required this.id});

  @override
  State<box> createState() => _boxState();
}

class _boxState extends State<box> {
  String name = "Name";
  String amount = '0';
  String date = "29th February 2024";

  Future<http.Response> fetchdata() async {
    final response =
        http.get(Uri.parse('http://10.0.2.2:5000/transaction/${widget.id}'));
    response.then((res) {
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        setState(() {
          name = data['name'];
          date = data['date'];
          amount = data['amount'].toStringAsFixed(0);
        });
      } else {
        throw Exception('Failed to load ids');
      }
    });
    return response;
  }

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 65,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Color.fromARGB(239, 6, 134, 239),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Column(
            children: [
              Expanded(
                  flex: 2,
                  child: Text(name,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 30,
                          color: const Color.fromARGB(255, 20, 13, 13)))),
              Expanded(
                  flex: 1,
                  child: Text(date,
                      style: TextStyle(
                          fontSize: 15,
                          color: const Color.fromARGB(255, 20, 13, 13)))),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                color: const Color.fromARGB(255, 20, 13, 13),
                Icons.currency_rupee,
                size: 32.5,
              ),
              Text(amount,
                  style: TextStyle(
                      fontSize: 30,
                      color: const Color.fromARGB(255, 20, 13, 13))),
            ],
          ),
        ));
  }
}
