import 'package:flutter_test/flutter_test.dart';
import 'package:vegan_app/models/e_number.dart';

void main() {
  group('ENumberItem', () {
    test('fromJson creates correct ENumberItem', () {
      final json = {
        'name_fr': 'Acide citrique',
        'alternative_names': ['E330', 'Citrate'],
        'e_number': 'E330',
        'state': 'vegan',
        'description_fr': 'Un acide naturel présent dans les agrumes.',
        'sources': [
          {
            'type': 'url',
            'value': 'https://fr.wikipedia.org/wiki/Acide_citrique'
          }
        ],
        'vegan_alternatives': ['Test alt']
      };

      final item = ENumberItem.fromJson(json);

      expect(item.name, 'Acide citrique');
      expect(item.alternativeNames, ['E330', 'Citrate']);
      expect(item.eNumber, 'E330');
      expect(item.state, 'vegan');
      expect(item.description, 'Un acide naturel présent dans les agrumes.');
      expect(item.sources.length, 1);
      expect(item.sources[0], isA<Source>());
      expect(item.sources[0].type, 'url');
      expect(item.sources[0].value,
          'https://fr.wikipedia.org/wiki/Acide_citrique');
      expect(item.veganAlternatives, ['Test alt']);
    });

    test('fromJsonList creates a list of ENumberItem with all fields', () {
      final json = {
        'items': [
          {
            'name_fr': 'Acide citrique',
            'alternative_names': ['E330'],
            'e_number': 'E330',
            'state': 'vegan',
            'description_fr': 'Un acide naturel.',
            'sources': [
              {
                'type': 'url',
                'value': 'https://fr.wikipedia.org/wiki/Acide_citrique'
              }
            ],
            'vegan_alternatives': ['Acide malique']
          },
          {
            'name_fr': 'Acide tartrique',
            'alternative_names': ['E334'],
            'e_number': 'E334',
            'state': 'vegan',
            'description_fr': 'Un autre acide.',
            'sources': [
              {
                'type': 'url',
                'value': 'https://fr.wikipedia.org/wiki/Acide_tartrique'
              }
            ],
            'vegan_alternatives': ['Acide citrique']
          }
        ]
      };

      final items = ENumberItem.fromJsonList(json);

      expect(items.length, 2);

      expect(items[0].name, 'Acide citrique');
      expect(items[0].alternativeNames, ['E330']);
      expect(items[0].eNumber, 'E330');
      expect(items[0].state, 'vegan');
      expect(items[0].description, 'Un acide naturel.');
      expect(items[0].sources.length, 1);
      expect(items[0].sources[0].value,
          'https://fr.wikipedia.org/wiki/Acide_citrique');
      expect(items[0].veganAlternatives, ['Acide malique']);

      expect(items[1].name, 'Acide tartrique');
      expect(items[1].alternativeNames, ['E334']);
      expect(items[1].eNumber, 'E334');
      expect(items[1].state, 'vegan');
      expect(items[1].description, 'Un autre acide.');
      expect(items[1].sources.length, 1);
      expect(items[1].sources[0].value,
          'https://fr.wikipedia.org/wiki/Acide_tartrique');
      expect(items[1].veganAlternatives, ['Acide citrique']);
    });
  });
}
