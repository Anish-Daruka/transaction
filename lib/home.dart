import 'package:flutter/material.dart';
import 'box.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<int> ids = [];
  String selected = "Last Month";
  String item1 = "Last Month";
  String item2 = "Last Week";
  double weektotal = 0;
  double monthtotal = 0;
  double total = 0;
  @override
  void initState() {
    super.initState();
    fetchids();
    fetchdatas();
  }

  @override
  Widget build(BuildContext context) {
    print("rebuilding");

    return Center(
      child: Stack(
        children: [
          ListView(
            scrollDirection: Axis.vertical,
            children: <Widget>[
              summary(),
              for (int i in ids) box(id: i),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: SizedBox(
              height: 70,
              width: 70,
              child: FloatingActionButton(
                onPressed: () {
                  inputbox(context);
                },
                child: Icon(Icons.add, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> inputbox(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController amountController = TextEditingController();

        return AlertDialog(
          title: Text("Add Transaction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Add"),
              onPressed: () {
                String name = nameController.text;
                double amount = double.tryParse(amountController.text) ?? 0;
                update(name, amount);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<http.Response> fetchids() async {
    print("fetching the ids");
    final response =
        await http.get(Uri.parse('http://10.0.2.2:5000/transaction_ids'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        ids = List<int>.from(data);
      });
    } else {
      throw Exception('Failed to load ids');
    }
    ;
    return response;
  }

  Future<void> fetchdatas() async {
    print("fetching the data");
    final response =
        await http.get(Uri.parse('http://10.0.2.2:5000/monthly_weekly_budget'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        weektotal = data['weekly_expenses'];
        monthtotal = data['month_expenses'];
        total = monthtotal;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<http.Response> update(String name, double amount) async {
    return http
        .post(
      Uri.parse('http://10.0.2.2:5000/transactions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'category': name,
        'amount': amount,
      }),
    )
        .then((response) async {
      if (response.statusCode == 201) {
        await fetchdatas();
        await fetchids();
        print('Transaction added successfully');
      } else {
        print('Failed to add transaction');
      }
      return response;
    });
  }

  Container summary() {
    return Container(
      height: 50,
      width: 100,
      padding: EdgeInsets.all(0),
      margin: const EdgeInsets.only(top: 5),
      color: const Color.fromARGB(255, 6, 106, 246),

      //set the text color to white
      child: Row(
        mainAxisSize:
            MainAxisSize.min, // Ensures the Row's width matches its children
        crossAxisAlignment:
            CrossAxisAlignment.center, // Aligns children vertically
        children: [
          Text("  $selected",
              style: TextStyle(color: Colors.white, fontSize: 20)),
          Expanded(child: Text('')),
          Icon(
            Icons.currency_rupee,
            size: 30,
            color: Colors.white,
          ),
          Text(
            total.toStringAsFixed(0),
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
            ),
          ),
          PopupMenuButton(
            color: Colors.white,
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                  value: item1,
                  child: Text(item1, style: TextStyle()),
                ),
                PopupMenuItem<String>(
                  value: item2,
                  child: Text(item2),
                ),
              ];
            },
            onSelected: (String value) {
              setState(() {
                selected = value;
                if (value == item1) {
                  total = monthtotal;
                } else {
                  total = weektotal;
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
