import 'dart:async';
import 'dart:convert';
import 'package:clean_architecture_app/features/notes/domain/entities/note.dart';
import 'package:clean_architecture_app/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
  }

  void checkInternetConnection() async {
    // Verify internet connection on first open
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      final prefs = await SharedPreferences.getInstance();
      // Check if notes were added offline
      if (prefs.containsKey('addNoteOffline')) {
        String? encodedNotesCache = prefs.getString('addNoteOffline');
        prefs.remove('addNoteOffline');
        if (encodedNotesCache != null) {
          List<dynamic> decodedList = json.decode(encodedNotesCache);
          List<Note> notes = decodedList.map((map) => Note.fromMap(map)).toList();

          final BuildContext currentContext = context;
          Future.microtask(() {
            final notesBloc = currentContext.read<NotesBlocModify>();
            notesBloc.add(AddNotes(notes: notes));
          });
        }
      }
      // Check if notes were deleted offline
      if (prefs.containsKey('deleteNoteOffline')){
        // print('Notes deleted offline');
        String? encodedPksCache = prefs.getString('deleteNoteOffline');
        if (encodedPksCache != null) {
          final BuildContext currentContext = context;
          Future.microtask((() {
            final notesBloc = currentContext.read<NotesBlocModify>();
            notesBloc.add(DeleteNote(note: Note(id: 0, title: 'deleted', body: 'deleted')));
          }));
        }
      }
      // Check if notes were edited offline
      if (prefs.containsKey('updateNoteOffline')){
        // print('Notes edited offline');
        String? encodedNotesEditedCache = prefs.getString('updateNoteOffline');
        if (encodedNotesEditedCache != null) {
          final BuildContext currentContext = context;
          Future.microtask((() {
            final notesBloc = currentContext.read<NotesBlocModify>();
            notesBloc.add(UpdateNote(note: Note(id: 0, title: 'edited', body: 'edited')));
          }));
        }
      }
    } else {
      final BuildContext currentContext = context;
      Future.microtask(() {
        final notesBloc = currentContext.read<NotesBloc>();
        notesBloc.add(GetNotesOffline());
        const snackBar = SnackBar(
          content: Text('No internet connection'),
          duration: Duration(days: 365),
        );
        ScaffoldMessenger.of(currentContext).showSnackBar(snackBar);
      });
    }

    // Verify connectivity changes
    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile) {
        final prefs = await SharedPreferences.getInstance();
        // Check if notes were added offline
        if (prefs.containsKey('addNoteOffline')){
          // print('Notes added offline');
          String? encodedNotesCache = prefs.getString('addNoteOffline');
          prefs.remove('addNoteOffline');
          if (encodedNotesCache != null) {
            List<dynamic> decodedList = json.decode(encodedNotesCache);
            List<Note> notes = decodedList.map((map) => Note.fromMap(map)).toList();

            final BuildContext currentContext = context;
            Future.microtask((() {
              final notesBloc = currentContext.read<NotesBlocModify>();
              notesBloc.add(AddNotes(notes: notes));
            }));
          }
        }
        // Check if notes were deleted offline
        if (prefs.containsKey('deleteNoteOffline')){
          // print('Notes deleted offline');
          String? encodedPksCache = prefs.getString('deleteNoteOffline');
          if (encodedPksCache != null) {
            final BuildContext currentContext = context;
            Future.microtask((() {
              final notesBloc = currentContext.read<NotesBlocModify>();
              notesBloc.add(DeleteNote(note: Note(id: 0, title: 'deleted', body: 'deleted')));
            }));
          }
        }
        // Check if notes were edited offline
        if (prefs.containsKey('updateNoteOffline')){
          // print('Notes edited offline');
          String? encodedNotesEditedCache = prefs.getString('updateNoteOffline');
          if (encodedNotesEditedCache != null) {
            final BuildContext currentContext = context;
            Future.microtask((() {
              final notesBloc = currentContext.read<NotesBlocModify>();
              notesBloc.add(UpdateNote(note: Note(id: 0, title: 'edited', body: 'edited')));
            }));
          }
        }
        final BuildContext currentContext = context;
        Future.microtask((() async {
          final notesBloc = currentContext.read<NotesBloc>();
          // notesBloc.add(GetNotes());
          await Future.delayed(const Duration(milliseconds: 95)).then((value) => notesBloc.add(GetNotes())).then((value) => ScaffoldMessenger.of(currentContext).clearSnackBars());
          // ScaffoldMessenger.of(currentContext).clearSnackBars();
        }));
      } else {
        context.read<NotesBloc>().add(GetNotesOffline());
        const snackBar = SnackBar(
          content: Text('No internet connection'),
          duration: Duration(days: 365),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 22, 22),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 22, 22, 22),
        elevation: 0,
        toolbarHeight: 110,
        title: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Text(
            'Mis Notas',
            style: TextStyle(
                fontSize: 30, color: Color.fromARGB(220, 255, 255, 255)),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Image.asset('assets/images/pencil_icon.png'),
            iconSize: 35,
            tooltip: 'Agregar nota',
            onPressed: () {
              createNotePopUp(context);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              iconSize: 30,
              color: const Color.fromARGB(220, 255, 255, 255),
              tooltip: 'Actualizar lista',
              onPressed: () async {
                await (Connectivity().checkConnectivity()).then(((connectivityResult) {
                  if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
                  BlocProvider.of<NotesBloc>(context).add(GetNotes());
                }
                }));
              },
            ),
          )
        ],
      ),
      body: BlocBuilder<NotesBloc, NotesState>(builder: (context, state) {
        if (state is Loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is Loaded) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
              child: Column(
                  children: state.notes.map((note) {
                TextEditingController noteTitle = TextEditingController(text: note.title);
                TextEditingController noteBody = TextEditingController(text: note.body);
                return Container(
                  margin: const EdgeInsets.only(left: 5, right: 5, bottom: 15),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color.fromARGB(255, 34, 34, 36),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(255, 17, 17, 17),
                        blurRadius: 4.0, // soften the shadow
                        spreadRadius: -1.5, //extend the shadow
                        offset: Offset(
                          0.5,
                          2.5,
                        ),
                      )
                    ],
                  ),
                  child: ListTile(
                    // leading: Text(note.id.toString()),
                    title: Text(
                      note.title,
                      style: const TextStyle(
                          color: Color.fromARGB(185, 255, 255, 255),
                          fontSize: 20),
                    ),
                    subtitle: Text(
                      note.body,
                      style: const TextStyle(
                          color: Color.fromARGB(140, 255, 255, 255)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor:
                                      const Color.fromARGB(255, 34, 34, 36),
                                  title: Row(
                                    children: const [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.white70,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Editar nota',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                  content: SizedBox(
                                    height: 150,
                                    child: Column(
                                      children: [
                                        TextField(
                                          controller: noteTitle,
                                          maxLength: 20,
                                          style: const TextStyle(
                                              color: Colors.white70),
                                          decoration: const InputDecoration(
                                            hintText: 'Titulo',
                                            hintStyle: TextStyle(
                                                color: Colors.white38),
                                          ),
                                        ),
                                        TextField(
                                          controller: noteBody,
                                          maxLength: 80,
                                          style: const TextStyle(
                                              color: Colors.white70),
                                          decoration: const InputDecoration(
                                            hintText: 'Descripción',
                                            hintStyle: TextStyle(
                                                color: Colors.white38),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        var noteUpdate = Note(id: note.id, title: noteTitle.text, body: noteBody.text);
                                        await (Connectivity().checkConnectivity()).then(((connectivityResult) async {
                                          if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
                                            // print('internet');
                                            BlocProvider.of<NotesBlocModify>(context).add(UpdateNote(note: noteUpdate));
                                            Navigator.of(context).pop();
                                            await Future.delayed(const Duration(milliseconds: 95)).then((value) => BlocProvider.of<NotesBloc>(context).add(GetNotes()));
                                          }else{
                                            // print('no internet');
                                            final prefs = await SharedPreferences.getInstance();
                                            if (prefs.containsKey('updateNoteOffline')){
                                              // print('exists');
                                              String? encodedNotesUpdateCache = prefs.getString('updateNoteOffline');
                                              prefs.remove('updateNoteOffline');
                                              if (encodedNotesUpdateCache != null) {
                                                List<dynamic> decodedList = json.decode(encodedNotesUpdateCache);
                                                List<Note> notes = decodedList.map((map) => Note.fromMap(map)).toList();

                                                notes.add(noteUpdate);
                                                List<Map<String, dynamic>> encodedList = notes.map((noteU) => noteU.toMap()).toList();
                                                String encodedNotes = json.encode(encodedList);
                                                prefs.setString('updateNoteOffline', encodedNotes);
                                              }
                                            } else {
                                              // print('not exists');
                                              List<Note> notes = [];
                                              notes.add(noteUpdate);
                                              List<Map<String, dynamic>> encodedList = notes.map((noteU) => noteU.toMap()).toList();
                                              String encodedNotesUpdateCache = json.encode(encodedList);
                                              prefs.setString('updateNoteOffline', encodedNotesUpdateCache);
                                            }
                                            final BuildContext currentContext = context;
                                            Future.microtask((() {
                                              Navigator.of(currentContext).pop();
                                              ScaffoldMessenger.of(currentContext).clearSnackBars();
                                            }));
                                            const snackBar = SnackBar(
                                              content: Text('No internet connection. Pending Changes.'),
                                              duration: Duration(days: 365),
                                            );
                                            Future.microtask((() {
                                              ScaffoldMessenger.of(currentContext).showSnackBar(snackBar);
                                            }));
                                          }
                                        }));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.deepPurple,
                                        shape: (RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        )),
                                      ),
                                      child: const Text('Actualizar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white70,
                          ),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                    'Confirmación',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: Text(
                                      '¿Está seguro de que desea eliminar ${note.title}?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text(
                                        'Cancelar',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color:
                                                Colors.red), // borde del botón
                                        backgroundColor: Colors
                                            .red, // color de fondo del botón
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      child: const Text(
                                        'Eliminar',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        await (Connectivity().checkConnectivity()).then(((connectivityResult) async {
                                          if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
                                            // print('internet');
                                            BlocProvider.of<NotesBlocModify>(context).add(DeleteNote(note: note));
                                            Navigator.of(context).pop();
                                            await Future.delayed(const Duration(milliseconds: 95)).then((value) => BlocProvider.of<NotesBloc>(context).add(GetNotes()));
                                          }else{
                                            // print('no internet');
                                            final prefs = await SharedPreferences.getInstance();
                                            if (prefs.containsKey('deleteNoteOffline')){
                                              // print('exists');
                                              String? encodedPkCache = prefs.getString('deleteNoteOffline');
                                              prefs.remove('deleteNoteOffline');
                                              if (encodedPkCache != null) {
                                                List<dynamic> decodedList = json.decode(encodedPkCache);
                                                List<Note> notes = decodedList.map((map) => Note.fromMap(map)).toList();

                                                notes.add(note);
                                                List<Map<String, dynamic>> encodedList = notes.map((note) => note.toMap()).toList();
                                                String encodedNotes = json.encode(encodedList);
                                                prefs.setString('deleteNoteOffline', encodedNotes);
                                              }
                                            } else {
                                              // print('not exists');
                                              List<Note> notes = [];
                                              notes.add(note);
                                              List<Map<String, dynamic>> encodedList = notes.map((note) => note.toMap()).toList();
                                              String encodedPks = json.encode(encodedList);
                                              prefs.setString('deleteNoteOffline', encodedPks);
                                            }
                                            final BuildContext currentContext = context;
                                            Future.microtask((() {
                                              Navigator.of(currentContext).pop();
                                              ScaffoldMessenger.of(currentContext).clearSnackBars();
                                            }));
                                            const snackBar = SnackBar(
                                              content: Text('No internet connection. Pending Changes.'),
                                              duration: Duration(days: 365),
                                            );
                                            Future.microtask((() {
                                              ScaffoldMessenger.of(currentContext).showSnackBar(snackBar);
                                            }));
                                          }
                                        }));
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList()),
            ),
          );
        } else if (state is Error) {
          return Center(
            child: Text(state.error, style: const TextStyle(color: Colors.red)),
          );
        } else {
          return Container();
        }
      }),
    );
  }

  createNotePopUp(BuildContext context) {
    TextEditingController noteTitle = TextEditingController();
    TextEditingController noteBody = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 34, 34, 36),
          title: Row(
            children: const [
              Icon(
                Icons.edit,
                color: Colors.white70,
              ),
              SizedBox(width: 10),
              Text(
                'Añadir nota',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          content: SizedBox(
            height: 140,
            child: Column(
              children: [
                TextField(
                  controller: noteTitle,
                  maxLength: 20,
                  style: const TextStyle(color: Colors.white70),
                  decoration: const InputDecoration(
                    hintText: 'Titulo',
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
                TextField(
                  controller: noteBody,
                  maxLength: 80,
                  style: const TextStyle(color: Colors.white70),
                  decoration: const InputDecoration(
                    hintText: 'Descripción',
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                String titleText = noteTitle.text.trim();
                String bodyText = noteBody.text.trim();

                if (titleText.isNotEmpty && bodyText.isNotEmpty) {
                  var note = Note(id: 0, title: noteTitle.text, body: noteBody.text);
                  await (Connectivity().checkConnectivity()).then(((connectivityResult) async {
                    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
                    // print('internet');
                    List<Note> notes = [];
                    notes.add(note);
                    BlocProvider.of<NotesBlocModify>(context).add(AddNotes(notes: notes));
                    Navigator.of(context).pop();
                    await Future.delayed(const Duration(milliseconds: 95)).then((value) => BlocProvider.of<NotesBloc>(context).add(GetNotes()));
                  } else{
                    // print('no internet');
                    final prefs = await SharedPreferences.getInstance();
                    if (prefs.containsKey('addNoteOffline')){
                      // print('exists');
                      String? encodedNotesCache = prefs.getString('addNoteOffline');
                      prefs.remove('addNoteOffline');
                      if (encodedNotesCache != null) {
                        List<dynamic> decodedList = json.decode(encodedNotesCache);
                        List<Note> notes = decodedList.map((map) => Note.fromMap(map)).toList();

                        notes.add(note);
                        List<Map<String, dynamic>> encodedList = notes.map((note) => note.toMap()).toList();
                        String encodedNotes = json.encode(encodedList);
                        prefs.setString('addNoteOffline', encodedNotes);
                      }
                    } else {
                      // print('not exists');
                      List<Note> notes = [];

                      notes.add(note);
                      List<Map<String, dynamic>> encodedList = notes.map((note) => note.toMap()).toList();
                      String encodedNotes = json.encode(encodedList);
                      prefs.setString('addNoteOffline', encodedNotes);
                    }
                    final BuildContext currentContext = context;
                    Future.microtask((() {
                      Navigator.of(currentContext).pop();
                      ScaffoldMessenger.of(currentContext).clearSnackBars();
                    }));
                    const snackBar = SnackBar(
                      content: Text('No internet connection. Pending Changes.'),
                      duration: Duration(days: 365),
                    );
                    Future.microtask((() {
                      ScaffoldMessenger.of(currentContext).showSnackBar(snackBar);
                    }));
                  }
                  }));
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromARGB(220, 255, 255, 255),
                backgroundColor: Colors.deepPurple,
                shape: (RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                )),
              ),
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }
}
