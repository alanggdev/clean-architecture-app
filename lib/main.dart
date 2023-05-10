import 'package:clean_architecture_app/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:clean_architecture_app/features/notes/presentation/pages/notes_page.dart';
import 'package:clean_architecture_app/usercase_config.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

UsecaseConfig usecaseConfig = UsecaseConfig();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NotesBloc>(
          create: (BuildContext context) => NotesBloc(getNotesUsecase: usecaseConfig.getNotesUsecase!)
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: const PostsPage(),
      ),
    );
  }
}