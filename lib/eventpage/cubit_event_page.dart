import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../db/database.dart';
import '../db/shared_preferences_provider.dart';
import '../events.dart';
import '../notes.dart';

import 'states_event_page.dart';

class CubitEventPage extends Cubit<StatesEventPage> {
  CubitEventPage() : super(StatesEventPage());

  final DatabaseProvider _databaseProvider = DatabaseProvider();

  void init(Notes notes) async {
    setCurrentNote(notes);
    setCurrentEventsList(<EventPageMessages>[]);
    setSelectedIconIndex(-1);
    setTextEditState(false);
    setTextSearchState(false);
    setAddingPhotoState(false);
    setSendPhotoButtonState(true);
    setSortedByBookmarksState(false);
    setSelectedItemIndex(-1);
    setSelectedPageReplyIndex(0);
    setSelectedDate('');
    setSelectedTime('');
    initSharedPreferences();
    setCurrentEventsList(
        await _databaseProvider.fetchEventsList(state.note.notesId));
  }

  void setSortedByBookmarksState(bool isSorted) =>
      emit(state.copyWith(isSortedByBookmarks: isSorted));

  void setCurrentNote(Notes note) => emit(state.copyWith(note: note));

  void setAddingPhotoState(bool isAddingPhoto) =>
      emit(state.copyWith(isAddingPhoto: isAddingPhoto));

  void setSendPhotoButtonState(bool isSendPhotoButton) =>
      emit(state.copyWith(isSendPhotoButton: isSendPhotoButton));

  void setTextEditState(bool isEditing) =>
      emit(state.copyWith(isEditing: isEditing));

  void setTextSearchState(bool isSearch) =>
      emit(state.copyWith(isSearch: isSearch));

  void setSelectedItemIndex(int selectedItemIndex) =>
      emit(state.copyWith(selectedItemIndex: selectedItemIndex));

  void setSelectedPageReplyIndex(int selectedPageReplyIndex) =>
      emit(state.copyWith(selectedPageReplyIndex: selectedPageReplyIndex));

  void setCurrentEventsList(List<EventPageMessages> currentEventsList) =>
      emit(state.copyWith(currentEventsList: currentEventsList));

  void setSelectedIconIndex(int index) =>
      emit(state.copyWith(selectedIconIndex: index));

  void setSelectedDate(String selectedDate) =>
      emit(state.copyWith(selectedDate: selectedDate ?? selectedDate));

  void setSelectedTime(String selectedTime) =>
      emit(state.copyWith(selectedTime: selectedTime));

  void initSharedPreferences() {
    emit(state.copyWith(
      isDateTimeModification:
      SharedPreferencesProvider().fetchDateTimeModification(),
      isBubbleAlignment: SharedPreferencesProvider().fetchBubbleAlignment(),
      isCenterDateBubble: SharedPreferencesProvider().fetchCenterDateBubble(),
    ));
  }

  void resetDateTimeModifications() =>
      emit(state.copyWith(selectedTime: '', selectedDate: ''));

  void editText(int index, String text) {
    state.currentEventsList[index].text = text;
    state.currentEventsList[index].circleAvatarIndex = state.selectedIconIndex;
    setSelectedItemIndex(-1);
    setTextEditState(false);
  }

  void sortEventsByDate() {
    state.currentEventsList
      ..sort(
            (a, b) {
          final aDate = DateFormat().add_yMMMd().parse(a.date);
          final bDate = DateFormat().add_yMMMd().parse(b.date);
          return bDate.compareTo(aDate);
        },
      );
    setCurrentEventsList(state.currentEventsList);
  }

  void deleteEvent(int index) {
    _databaseProvider.deleteEvent(state.currentEventsList[index]);
    state.currentEventsList.removeAt(index);
    setCurrentEventsList(state.currentEventsList);
  }

  void removeSelectedIcon() => setSelectedIconIndex(-1);

  void updateNote() => _databaseProvider.updateNote(state.note);

  void addEvent(String text) async {
    final event = EventPageMessages(
      date: state.selectedDate != ''
          ? state.selectedDate
          : DateFormat.yMMMd().format(
        DateTime.now(),
      ),
      imagePath: null,
      circleAvatarIndex: state.selectedIconIndex,
      text: text,
      bookmarkIndex: 0,
      currentNoteId: state.note.notesId,
      time: state.selectedTime != ''
          ? state.selectedTime
          : DateFormat('hh:mm a').format(
        DateTime.now(),
      ),
    );
    state.currentEventsList.insert(0, event);
    setCurrentEventsList(state.currentEventsList);
    event.eventId = await _databaseProvider.insertEvents(event);
  }

  void updateBookmark(int index) {
    state.currentEventsList[index].bookmarkIndex == 0
        ? state.currentEventsList[index].bookmarkIndex = 1
        : state.currentEventsList[index].bookmarkIndex = 0;
    setCurrentEventsList(state.currentEventsList);
    _databaseProvider.updateEvent(state.currentEventsList[index]);
  }

  Future<void> addImageEvent(File image) async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final savedImage = await image.copy('${appDirectory.path}/$fileName');
    final event = EventPageMessages(
      date: state.selectedDate != ''
          ? state.selectedDate
          : DateFormat.yMMMd().format(
        DateTime.now(),
      ),
      time: state.selectedTime != ''
          ? state.selectedTime
          : DateFormat('hh:mm a').format(
        DateTime.now(),
      ),
      text: '',
      bookmarkIndex: 0,
      imagePath: savedImage.path,
      currentNoteId: state.note.notesId,
    );
    event.circleAvatarIndex = -1;
    setAddingPhotoState(false);
    state.currentEventsList.insert(0, event);
    event.eventId = await _databaseProvider.insertEvents(event);
  }

  void transferEvent(List<Notes> noteList, int index) async {
    final replySubtitle = state.currentEventsList[index].imagePath == null
        ? '${state.currentEventsList[index].text}  ${state.currentEventsList[index].time}'
        : 'Image';
    final event = EventPageMessages(
      date: state.currentEventsList[index].date,
      text: state.currentEventsList[index].text,
      time: state.currentEventsList[index].time,
      bookmarkIndex: state.currentEventsList[index].bookmarkIndex,
      imagePath: state.currentEventsList[index].imagePath,
      currentNoteId: noteList[state.selectedPageReplyIndex].notesId,
      circleAvatarIndex: state.currentEventsList[index].circleAvatarIndex,
    );
    noteList[state.selectedPageReplyIndex].notesSubtitle = replySubtitle;
    deleteEvent(index);
    event.eventId = await _databaseProvider.insertEvents(event);
  }
}