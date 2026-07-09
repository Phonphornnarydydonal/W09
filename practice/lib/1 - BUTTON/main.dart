import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SelectedButton(),
    ),
  );
}

class Button {
  final String title;
  final bool selected;

  Button({required this.title, required this.selected});
  static Button fromJson(Map<String, dynamic> json) {
    const String titleKey = 'title';
    const String selectedKey = 'selected';
    assert(json[titleKey] is String);
    assert(json[selectedKey] is bool);
    return Button(title: json[titleKey], selected: json[selectedKey]);
  }
}

class Repo {
  static final Repo instance = Repo();
  Future<Button> getData() async {
    try {
      final url = Uri.parse(
        "https://buttomstatus-default-rtdb.asia-southeast1.firebasedatabase.app/buttonstatus.json",
      );
      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception("Failed : ${response.statusCode}");
      }
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Button.fromJson(data);
    } catch (e) {
      throw Exception("Connection Error : $e");
    }
  }
}

enum AsyncState { loading, success, error }

class SelectedButton extends StatefulWidget {
  const SelectedButton({super.key});
  @override
  State<SelectedButton> createState() => SelectedButtonState();
}

class SelectedButtonState extends State<SelectedButton> {
  AsyncState state = AsyncState.loading;
  Button? button;
  bool isSelect = false;
  @override
  void initState() {
    super.initState();
    fetchButton();
  }

  Future<void> fetchButton() async {
    setState(() {
      state = AsyncState.loading;
    });
    try {
      button = await Repo.instance.getData();
      isSelect = button!.selected;
      setState(() {
        state = AsyncState.success;
      });
    } catch (e) {
      print(e);
      setState(() {
        state = AsyncState.error;
      });
    }
  }

  void onPress() {
    setState(() {
      isSelect = !isSelect;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (state) {
      case AsyncState.loading:
        body = const Center(child: CircularProgressIndicator());
        break;
      case AsyncState.error:
        body = const Center(child: Text("Error fetching data"));
        break;
      case AsyncState.success:
        body = Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelect ? Colors.blue : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            onPressed: onPress,
            child: Text(button!.title, style: const TextStyle(fontSize: 20)),
          ),
        );
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Button")),
      body: body,
    );
  }
}
