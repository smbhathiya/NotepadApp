import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notepad/constants/colors.dart';
import 'package:notepad/models/note.dart';
import 'package:notepad/screens/edit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> filteredNotes = [];
  bool sorted = false;
  List<Note> sampleNotes = [];

  @override
  void initState() {
    super.initState();
    // Load saved notes from SharedPreferences
    loadNotes();
    // Initialize filteredNotes with all notes
    filteredNotes = List.from(sampleNotes);
  }

  List<Note> sortNotes(List<Note> notes) {
    if (sorted) {
      notes.sort((b, a) => a.modifiedTime.compareTo(b.modifiedTime));
    } else {
      notes.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));
    }
    sorted = !sorted;
    return notes;
  }

  getRandomColor() {
    Random random = Random();
    return backgroundColors[random.nextInt(backgroundColors.length)];
  }

  void onSearchText(String searchText) {
    setState(() {
      filterNotes(searchText);
    });
  }

  void filterNotes(String searchText) {
    filteredNotes = sampleNotes
        .where((note) =>
            note.content.toLowerCase().contains(searchText.toLowerCase()) ||
            note.title.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  Future<void> loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notesData = prefs.getStringList('notes');
    if (notesData != null) {
      setState(() {
        sampleNotes = notesData.map((data) {
          List<String> parts = data.split(',');
          return Note(
            id: int.parse(parts[0]),
            title: parts[1],
            content: parts[2],
            modifiedTime: DateTime.parse(parts[3]),
          );
        }).toList();

        // Update filteredNotes after loading notes
        filteredNotes = List.from(sampleNotes);
      });
    }
  }

  Future<void> saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesData = sampleNotes.map((note) {
      return '${note.id},${note.title},${note.content},${note.modifiedTime.toIso8601String()}';
    }).toList();
    prefs.setStringList('notes', notesData);
  }

  Future<void> addNoteToList(List result) async {
    setState(() {
      sampleNotes.insert(
        0,
        Note(
          id: sampleNotes.length,
          title: result[0],
          content: result[1],
          modifiedTime: DateTime.now(),
        ),
      );
      filterNotes(""); // Refresh the filtered notes with an empty search string
      saveNotes();
    });
  }

  void deleteNote(int index) {
    setState(() {
      Note note = filteredNotes[index];
      sampleNotes.remove(note);
      filterNotes(""); // Refresh the filtered notes with an empty search string
      saveNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      filterNotes(""); // Reset the search when sorting
                      filteredNotes = sortNotes(filteredNotes);
                    });
                  },
                  padding: const EdgeInsets.all(0),
                  icon: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255)
                          .withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.note,
                      color: Color.fromARGB(255, 0, 96, 240),
                      size: 35,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Notes',
                    style: TextStyle(
                        fontSize: 30,
                        color: Color.fromARGB(255, 0, 96, 240),
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              onChanged: onSearchText,
              style: const TextStyle(
                  fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                hintText: "Search notes",
                hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 255, 255, 255)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                fillColor: const Color.fromARGB(255, 243, 243, 243),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: ListView.builder(
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      //color: getRandomColor(),
                      color: const Color.fromARGB(255, 214, 214, 214),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => EditScreen(
                                  note: filteredNotes[index],
                                ),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                int originalIndex =
                                    sampleNotes.indexOf(filteredNotes[index]);
                                sampleNotes[originalIndex] = Note(
                                  id: sampleNotes[originalIndex].id,
                                  title: result[0],
                                  content: result[1],
                                  modifiedTime: DateTime.now(),
                                );
                                filteredNotes[index] = Note(
                                  id: sampleNotes[index].id,
                                  title: result[0],
                                  content: result[1],
                                  modifiedTime: DateTime.now(),
                                );
                                saveNotes();
                              });
                            }
                          },
                          title: RichText(
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: '${filteredNotes[index].title}\n',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                  text: sampleNotes[index].content,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Edited ${DateFormat('EEE MMM d, yyyy h:mm a').format(sampleNotes[index].modifiedTime)}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.normal,
                                color: Color.fromARGB(255, 109, 109, 109),
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () async {
                              final result = await conformationDialog(context);
                              if (result != null && result) {
                                deleteNote(index);
                              }
                            },
                            icon: const Icon(
                              Icons.delete,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<List>(
            context,
            MaterialPageRoute<List>(
              builder: (BuildContext context) => const EditScreen(),
            ),
          );

          if (result != null) {
            await addNoteToList(result);
          }
        },
        elevation: 2,
        backgroundColor: const Color.fromARGB(255, 35, 35, 35),
        child: const Icon(
          Icons.add,
          size: 38,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    );
  }

  Future<dynamic> conformationDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          icon: const Icon(Icons.info, color: Color.fromARGB(255, 0, 0, 0)),
          title: const Text(
            'Are you sure you want to delete?',
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const SizedBox(
                  child: Text(
                    'Yes',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const SizedBox(
                  child: Text(
                    'No',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
