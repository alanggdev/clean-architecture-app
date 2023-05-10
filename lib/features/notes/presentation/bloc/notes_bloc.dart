import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:clean_architecture_app/features/notes/domain/entities/note.dart';
import 'package:clean_architecture_app/features/notes/domain/usecases/add_note.dart';
import 'package:clean_architecture_app/features/notes/domain/usecases/delete_note.dart';
import 'package:clean_architecture_app/features/notes/domain/usecases/get_notes.dart';
import 'package:clean_architecture_app/features/notes/domain/usecases/update_note.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final GetNotesUsecase getNotesUsecase;

  NotesBloc({required this.getNotesUsecase}) : super(Loading()) {
    on<NotesEvent>((event, emit) async {
      if(event is GetNotes) {
        try {
          emit(Loading());
          List<Note> response = await getNotesUsecase.execute();
          emit(Loaded(notes: response));
        } catch (e) {
          emit(Error(error: e.toString()));
        }
      }
    });
  }
}

class NotesBlocModify extends Bloc<NotesEvent, NotesState> {
  final AddNoteUsecase addNoteUsecase;
  final UpdateNoteUsecase updateNoteUsecase;
  final DeleteNoteUsecase deleteNoteUsecase;

  NotesBlocModify({required this.addNoteUsecase, required this.updateNoteUsecase, required this.deleteNoteUsecase}) : super(Updating()) {
    on<NotesEvent>((event, emit) async {
      if(event is AddNotes) {
        try {
          emit(Updating());
          await addNoteUsecase.execute(event.note);
          emit(Updated());
        } catch (e) {
          emit(Error(error: e.toString()));
        }
      } else if(event is UpdateNote) {
        try {
          emit(Updating());
          await updateNoteUsecase.execute(event.note);
          emit(Updated());
        } catch (e) {
          emit(Error(error: e.toString()));
        }
      } else if(event is DeleteNote) {
        try {
          emit(Updating());
          await deleteNoteUsecase.execute(event.note);
          emit(Updated());
        } catch (e) {
          emit(Error(error: e.toString()));
        }
      }
    });
  }
}