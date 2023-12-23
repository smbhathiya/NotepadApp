import 'package:flutter/material.dart';
import 'package:notepad/models/note.dart';

class EditScreen extends StatefulWidget {
  final Note? note;
  const EditScreen({super.key, this.note});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController _titleControler = TextEditingController();
  TextEditingController _contentControler = TextEditingController();

  @override
  void initState() {
    if (widget.note != null) {
      _titleControler = TextEditingController(text: widget.note!.title);
      _contentControler = TextEditingController(text: widget.note!.content);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  padding: const EdgeInsets.all(0),
                  icon: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 78, 78, 78)
                              .withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      )))
            ],
          ),
          Expanded(
              child: ListView(
            children: [
              TextField(
                controller: _titleControler,
                style: const TextStyle(color: Colors.white, fontSize: 30),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 30),
                ),
              ),
              TextField(
                controller: _contentControler,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Note',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                ),
              ),
            ],
          ))
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(
              context, [_titleControler.text, _contentControler.text]);
        },
        elevation: 5,
        backgroundColor: Colors.grey.shade800,
        child: const Icon(Icons.save, color: Colors.white),
      ),
    );
  }
}
