class Notes {
  int notesId;
  int circleAvatarIndex;
  String notesTitle;
  String notesSubtitle;
  String date;

  Notes({this.notesId, this.circleAvatarIndex, this.notesTitle, this.notesSubtitle, this.date});

  Map<String, dynamic> convertNotesToMapWithId() {
    return {
      'note_id': notesId,
      'title': notesTitle,
      'sub_title': notesSubtitle,
      'note_circle_avatar_index': circleAvatarIndex,
      'date': date,
    };
  }

  Map<String, dynamic> convertNotesToMap() {
    return {
      'title': notesTitle,
      'sub_title': notesSubtitle,
      'note_circle_avatar_index': circleAvatarIndex,
      'date': date,
    };
  }

  factory Notes.fromMap(Map<String, dynamic> map) {
    return Notes(
      notesId: map['note_id'],
      notesTitle: map['title'],
      notesSubtitle: map['sub_title'],
      circleAvatarIndex: map['note_circle_avatar_index'],
      date: map['date'],
    );
  }
}