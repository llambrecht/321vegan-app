class ENumberItem {
  final String name;
  final List<String> alternativeNames;
  final String eNumber;
  final String state;
  final String description;
  final List<Source> sources;
  final List<String> veganAlternatives;

  ENumberItem({
    required this.name,
    required this.alternativeNames,
    required this.eNumber,
    required this.state,
    required this.description,
    required this.sources,
    required this.veganAlternatives,
  });

  static List<ENumberItem> fromJsonList(Map<String, dynamic> json) {
    var itemList = json['items'] as List;
    return itemList.map((itemJson) => ENumberItem.fromJson(itemJson)).toList();
  }

  factory ENumberItem.fromJson(Map<String, dynamic> json) {
    var altNamesFromJson = json['alternative_names'].cast<String>();
    var sourcesFromJson = json['sources']
        .map<Source>((item) => Source.fromJson(item))
        .toList()
        .cast<Source>();

    return ENumberItem(
      name: json['name_fr'],
      alternativeNames: altNamesFromJson,
      eNumber: json['e_number'],
      state: json['state'],
      description: json['description_fr'] ?? '',
      sources: sourcesFromJson,
      veganAlternatives: json['vegan_alternatives'].cast<String>(),
    );
  }
}

class Source {
  final String type;
  final String value;

  Source({required this.type, required this.value});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      type: json['type'],
      value: json['value'],
    );
  }
}
