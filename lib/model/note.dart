final String tableNotes = 'notes';

class NoteFields {
  static final List<String> values = [
    id, number, title, description
  ];

  static final String id = '_id';
  static final String number = 'number';
  static final String title = 'title';
  static final String description = 'description';
}

class Note {
  final int? id;
  final int number;
  final String title;
  final String description;

  const Note({
    this.id,
    required this.number,
    required this.title,
    required this.description

  });

  Map<String, Object?> toJson() => {
    NoteFields.id: id,
    NoteFields.number: number,
    NoteFields.title: title,
    NoteFields.description: description
  };

  Note copy({
  int? id,
  int? number,
  String? title,
  String? description
}) =>
      Note(
        id: id ?? this.id,
        number: number ?? this.number,
        title: title ?? this.title,
        description: description ?? this.description
      );

  static Note fromJson(Map<String, Object?> json) => Note(
    id: json[NoteFields.id] as int?,
    number: json[NoteFields.number] as int,
    title: json[NoteFields.title] as String,
    description: json[NoteFields.description] as String
  );

}