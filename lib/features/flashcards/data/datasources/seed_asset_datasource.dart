import 'dart:convert';

import 'package:flutter/services.dart';

/// DTO bruto representando um card vindo do arquivo de seed JSON.
class SeedCardDto {
  final String id;
  final String question;
  final String answer;

  const SeedCardDto({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory SeedCardDto.fromJson(Map<String, dynamic> json) {
    return SeedCardDto(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }
}

/// DTO bruto representando um deck vindo do arquivo de seed JSON.
class SeedDeckDto {
  final String id;
  final String title;
  final String description;
  final List<SeedCardDto> cards;

  const SeedDeckDto({
    required this.id,
    required this.title,
    required this.description,
    required this.cards,
  });

  factory SeedDeckDto.fromJson(Map<String, dynamic> json) {
    final rawCards = json['cards'] as List<dynamic>;
    return SeedDeckDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      cards: rawCards
          .map((e) => SeedCardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Lê e decodifica o arquivo `assets/seed/decks.json`.
class SeedAssetDatasource {
  static const String defaultAssetPath = 'assets/seed/decks.json';

  final AssetBundle _bundle;
  final String _assetPath;

  SeedAssetDatasource({
    AssetBundle? bundle,
    this._assetPath = defaultAssetPath,
  }) : _bundle = bundle ?? rootBundle;

  Future<List<SeedDeckDto>> loadDecks() async {
    final raw = await _bundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final decksJson = decoded['decks'] as List<dynamic>;
    return decksJson
        .map((e) => SeedDeckDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
