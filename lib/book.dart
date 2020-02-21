import 'package:json_annotation/json_annotation.dart';
part 'book.g.dart';

@JsonSerializable()

class Book {
  final String author;
  final String country;
  final String language;
  final int pages;
  final String title;
  final int year;

  Book(this.author, this.country, this.language, this.pages, this.title,
      this.year);

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$BookToJson(this);
}