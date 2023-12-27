import 'package:flutter/material.dart';
import 'package:notepad/models/note.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditScreen extends StatefulWidget {
  final Note? note;
  const EditScreen({super.key, this.note});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    if (widget.note != null) {
      _titleController = TextEditingController(text: widget.note!.title);
      _contentController = TextEditingController(text: widget.note!.content);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: const EdgeInsets.all(5),
                icon: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(2255, 0, 96, 240),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'Add New Note',
                  style: TextStyle(
                    fontSize: 25,
                    color: Color.fromARGB(255, 0, 96, 240),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: ListView(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color.fromARGB(255, 242, 242, 245)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: TextField(
                        controller: _titleController,
                        maxLines: null,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 28,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Title',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 350,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color.fromARGB(255, 242, 242, 245)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: TextField(
                        controller: _contentController,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 32, 32, 32),
                          fontSize: 20,
                        ),
                        maxLines: null,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Note',
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 28, 28, 28),
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await saveNote();

          // ignore: use_build_context_synchronously
          Navigator.pop(
            context,
            [_titleController.text, _contentController.text],
          );
        },
        elevation: 5,
        backgroundColor: const Color.fromARGB(207, 0, 0, 0),
        child:
            const Icon(Icons.save, color: Color.fromARGB(255, 255, 255, 255)),
      ),
    );
  }

  Future<void> saveNote() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesList = prefs.getStringList('notes') ?? [];

    if (widget.note != null) {
      // Update existing note
      int index = int.parse(widget.note!.id as String);
      notesList[index] =
          '${widget.note!.id},${_titleController.text},${_contentController.text}';
    } else {
      // Add new note
      int id = DateTime.now().millisecondsSinceEpoch;
      notesList.add('$id,${_titleController.text},${_contentController.text}');
    }

    // Save the updated list back to SharedPreferences
    prefs.setStringList('notes', notesList);
  }
}
