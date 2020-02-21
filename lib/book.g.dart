// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) {
  return Book(
    json['author'] as String,
    json['country'] as String,
    json['language'] as String,
    json['pages'] as int,
    json['title'] as String,
    json['year'] as int,
  );
}

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'author': instance.author,
      'country': instance.country,
      'language': instance.language,
      'pages': instance.pages,
      'title': instance.title,
      'year': instance.year,
    };
