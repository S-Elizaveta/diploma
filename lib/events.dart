class EventPageMessages {
  int eventId;
  int currentNoteId;
  int circleAvatarIndex;
  int bookmarkIndex;
  String text;
  String time;
  String imagePath;
  String date;

  EventPageMessages({this.eventId, this.currentNoteId, this.circleAvatarIndex, this.bookmarkIndex, this.text, this.time, this.imagePath, this.date});

  Map<String, dynamic> convertEventToMap() {
    return {
      'current_note_id': currentNoteId,
      'text': text,
      'time': time,
      'event_circle_avatar_index': circleAvatarIndex,
      'bookmark_index': bookmarkIndex,
      'image_path': imagePath,
      'date': date,
    };
  }
  Map<String, dynamic> convertEventToMapWithId() {
    return {
      'event_id': eventId,
      'current_note_id': currentNoteId,
      'text': text,
      'time': time,
      'event_circle_avatar_index': circleAvatarIndex,
      'bookmark_index': bookmarkIndex,
      'image_path': imagePath,
      'date': date,
    };
  }

  factory EventPageMessages.fromMap(Map<String, dynamic> map) {
    return EventPageMessages(
      eventId: map['event_id'],
      currentNoteId: map['current_note_id'],
      text: map['text'],
      time: map['time'],
      circleAvatarIndex: map['event_circle_avatar_index'],
      bookmarkIndex: map['bookmark_index'],
      imagePath: map['image_path'],
      date: map['date']
    );
  }

}