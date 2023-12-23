import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notepad/constants/colors.dart';
import 'package:notepad/models/note.dart';
import 'package:notepad/screens/edit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> filterdNotes = [];
  bool sorted = false;

  void initStat() {
    super.initState();
    filterdNotes = sampleNotes;
  }

  List<Note> sortNotes(List<Note> notes) {
    if (sorted) {
      notes.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));
    } else {
      notes.sort((b, a) => a.modifiedTime.compareTo(b.modifiedTime));
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
      filterdNotes = sampleNotes
          .where((note) =>
              note.content.toLowerCase().contains(searchText.toLowerCase()) ||
              note.title.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void deleteNote(int index) {
    setState(() {
      Note note = filterdNotes[index];
      sampleNotes.remove(note);
      filterdNotes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          filterdNotes = sortNotes(filterdNotes);
                        });
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
                            Icons.sort,
                            color: Colors.white,
                          )))
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                onChanged: onSearchText,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintText: "Search notes...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    fillColor: Colors.grey.shade800),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ListView.builder(
                  itemCount: filterdNotes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      color: getRandomColor(),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          onTap: () async {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => EditScreen(
                                    note: filterdNotes[index],
                                  ),
                                ));
                            if (result != null) {
                              setState(() {
                                int originalIndex =
                                    sampleNotes.indexOf(filterdNotes[index]);
                                sampleNotes[originalIndex] = Note(
                                    id: sampleNotes[originalIndex].id,
                                    title: result[0],
                                    content: result[1],
                                    modifiedTime: DateTime.now());
                                filterdNotes[index] = Note(
                                    id: sampleNotes[index].id,
                                    title: result[0],
                                    content: result[1],
                                    modifiedTime: DateTime.now());
                              });
                            }
                          },
                          title: RichText(
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                                text: '${filterdNotes[index].title}\n',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    height: 1.5),
                                children: [
                                  TextSpan(
                                    text: sampleNotes[index].content,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  )
                                ]),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Edited ${DateFormat('EEE MMM d, yyyy h:mm a').format(sampleNotes[index].modifiedTime)}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
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
              ))
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<List>(
            context,
            MaterialPageRoute<List>(
              builder: (BuildContext context) => const EditScreen(),
            ),
          );

          if (result != null) {
            setState(() {
              sampleNotes.add(Note(
                  id: sampleNotes.length,
                  title: result[0],
                  content: result[1],
                  modifiedTime: DateTime.now()));
              onSearchText("");
            });
          }
        },
        elevation: 2,
        backgroundColor: Colors.grey.shade800,
        child: const Icon(
          Icons.add,
          size: 38,
          color: Color.fromARGB(255, 213, 213, 213),
        ),
      ),
    );
  }

  Future<dynamic> conformationDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey.shade900,
            icon: const Icon(Icons.info, color: Colors.grey),
            title: const Text(
              'Are you sure you want to delete?',
              style: TextStyle(color: Colors.white),
            ),
            content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      child: const SizedBox(
                        child: Text('Yes',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)),
                      )),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const SizedBox(
                        child: Text('No',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)),
                      ))
                ]),
          );
        });
  }
}
