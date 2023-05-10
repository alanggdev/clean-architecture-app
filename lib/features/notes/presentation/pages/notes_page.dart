import 'package:clean_architecture_app/features/notes/data/datasources/note_remote.dart';
import 'package:clean_architecture_app/features/notes/data/repositories/note_repository_impl.dart';
import 'package:clean_architecture_app/features/notes/domain/entities/note.dart';
import 'package:clean_architecture_app/features/notes/domain/usecases/add_note.dart';
import 'package:clean_architecture_app/features/notes/domain/usecases/delete_note.dart';
import 'package:clean_architecture_app/features/notes/domain/usecases/get_notes.dart';
import 'package:clean_architecture_app/features/notes/domain/usecases/update_note.dart';

import 'package:clean_architecture_app/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(GetNotes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar inventario',
            onPressed: () {
              createInventoryPopUp(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista',
            onPressed: () async {
              BlocProvider.of<NotesBloc>(context).add(GetNotes());
            },
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
            child: Column(
                children: state.notes.map((note) {
              TextEditingController noteTitle =
                  TextEditingController(text: note.title);
              TextEditingController noteBody =
                  TextEditingController(text: note.body);
              return Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(5),
                color: Colors.black12,
                child: ListTile(
                  // leading: Text(note.id.toString()),
                  title: Text(note.title),
                  subtitle: Text(note.body),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Row(
                                  children: const [
                                    Icon(
                                      Icons.add,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Editar nota',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                content: SizedBox(
                                  height: 150,
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: noteTitle,
                                        maxLength: 15,
                                        decoration: const InputDecoration(
                                          hintText: 'Titulo',
                                        ),
                                      ),
                                      TextField(
                                        controller: noteBody,
                                        maxLength: 50,
                                        decoration: const InputDecoration(
                                          hintText: 'Descripción',
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
                                      var noteUpdate = Note(
                                          id: note.id,
                                          title: noteTitle.text,
                                          body: noteBody.text);
                                      await UpdateNoteUsecase(
                                          NoteRepositoryImpl(
                                        noteRemoteDataSource:
                                            NoteRemoteDataSourceImp(),
                                      )).execute(noteUpdate).then(((value) {
                                        BlocProvider.of<NotesBloc>(context)
                                            .add(GetNotes());
                                        Navigator.of(context).pop();
                                      }));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color(0xffff8e00),
                                      shape: (RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
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
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await DeleteNoteUsecase(NoteRepositoryImpl(
                            noteRemoteDataSource: NoteRemoteDataSourceImp(),
                          )).execute(note).then(((value) {
                            BlocProvider.of<NotesBloc>(context).add(GetNotes());
                            // Navigator.of(context).pop();
                          }));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList()),
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

  createInventoryPopUp(BuildContext context) {
    TextEditingController noteTitle = TextEditingController();
    TextEditingController noteBody = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(
                Icons.add,
              ),
              SizedBox(width: 10),
              Text(
                'Añadir nota',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                TextField(
                  controller: noteTitle,
                  maxLength: 15,
                  decoration: const InputDecoration(
                    hintText: 'Titulo',
                  ),
                ),
                TextField(
                  controller: noteBody,
                  maxLength: 50,
                  decoration: const InputDecoration(
                    hintText: 'Descripción',
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
                var note =
                    Note(id: 0, title: noteTitle.text, body: noteBody.text);
                await AddNoteUsecase(NoteRepositoryImpl(
                  noteRemoteDataSource: NoteRemoteDataSourceImp(),
                )).execute(note).then(((value) {
                  BlocProvider.of<NotesBloc>(context).add(GetNotes());
                  Navigator.of(context).pop();
                }));
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xffff8e00),
                shape: (RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
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
