import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:clean_architecture_app/features/notes/domain/entities/note.dart';
import 'package:clean_architecture_app/features/notes/domain/usecases/get_notes.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotesUsecase getNotesUsecase;

  NotesBloc({required this.getNotesUsecase}) : super(Loading()) {
    on<NotesEvent>((event, emit) async {
      if(event is GetNotes) {
        try {
          List<Note> response = await getNotesUsecase.execute();
          emit(Loaded(notes: response));
        } catch (e) {
          emit(Error(error: e.toString()));
        }
      }
    });
  }
}