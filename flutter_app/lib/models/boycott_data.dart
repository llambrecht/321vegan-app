class BoycottBrand {
  final String match;
  final String display;
  final List<String> aliases;

  const BoycottBrand(this.match, this.display, {this.aliases = const []});
}

class BoycottGroup {
  final String name;
  final String reason;
  final List<BoycottBrand> brands;

  const BoycottGroup({
    required this.name,
    required this.reason,
    required this.brands,
  });
}

class BoycottOther {
  final String match;
  final String display;
  final String reason;
  final List<String> aliases;

  const BoycottOther({
    required this.match,
    required this.display,
    required this.reason,
    this.aliases = const [],
  });
}

class BoycottMatch {
  final String brandDisplay;
  final String? groupName;
  final String reason;

  const BoycottMatch({
    required this.brandDisplay,
    this.groupName,
    required this.reason,
  });
}

class BoycottData {
  static const List<BoycottGroup> groups = [
    BoycottGroup(
      name: 'Mars Group',
      reason:
          'Mars est l\'un des plus grands pollueurs de plastiques au monde. Le groupe a également été lié au travail des enfants dans ses filières cacao en Afrique, à de la déforestation et à de la fixation illégale des prix. Mars a continué ses activités en Russie après l\'invasion de l\'Ukraine, ce qui lui a valu d\'être nommé sponsor international de la guerre par le gouvernement ukrainien.',
      brands: [
        BoycottBrand('mars', 'Mars'),
        BoycottBrand('dove', 'Dove'),
        BoycottBrand('bounty', 'Bounty'),
        BoycottBrand('ben\'s original', 'Ben\'s Original'),
        BoycottBrand('ben\'s', 'Ben\'s'),
        BoycottBrand('skittles', 'Skittles'),
        BoycottBrand('m&m\'s', 'M&M\'s'),
        BoycottBrand('snickers', 'Snickers'),
        BoycottBrand('ebly', 'Ebly'),
        BoycottBrand('suzi wan', 'Suzi Wan'),
      ],
    ),
    BoycottGroup(
      name: 'Carrefour Group',
      reason:
          'Carrefour a mis en danger ses employés (intoxications au monoxyde de carbone), et ses chaînes d\'approvisionnement ont été liées à de l\'esclavage moderne, de la maltraitance animale et de la déforestation illégale en Amazonie. L\'enseigne a aussi discriminé des clients LGBT et refusé d\'indemniser les familles de victimes de conditions de travail mortelles dans ses usines partenaires.',
      brands: [
        BoycottBrand('carrefour', 'Carrefour'),
        BoycottBrand('reflets de france', 'Reflets de France'),
        BoycottBrand('tex', 'Tex'),
        BoycottBrand('grand jury', 'Grand Jury'),
      ],
    ),
    BoycottGroup(
      name: 'Coca-Cola Company',
      reason:
          'Coca-Cola est le premier pollueur plastique mondial selon Forbes, produisant 200 000 bouteilles plastique par minute. L\'entreprise épuise par ailleurs les nappes phréatiques dans des régions déjà frappées par la sécheresse.',
      brands: [
        BoycottBrand('coca-cola', 'Coca-Cola', aliases: ['coca cola']),
        BoycottBrand('fanta', 'Fanta'),
        BoycottBrand('sprite', 'Sprite'),
        BoycottBrand('tropico', 'Tropico'),
        BoycottBrand('minute maid', 'Minute Maid'),
        BoycottBrand('powerade', 'Powerade'),
        BoycottBrand('monster', 'Monster'),
        BoycottBrand('fuze tea', 'Fuze Tea', aliases: ['fuzetea']),
        BoycottBrand('innocent', 'Innocent'),
        BoycottBrand('vitaminwater', 'Vitaminwater'),
      ],
    ),
    BoycottGroup(
      name: 'PepsiCo',
      reason:
          'PepsiCo est l\'un des plus grands pollueurs plastiques au monde et contribue à l\'épuisement des ressources en eau dans des zones en stress hydrique. Par ailleurs, PepsiCo est copropriétaire de Sabra, en partenariat avec le groupe israélien Strauss, dont une division finance directement des unités de l\'armée israélienne.',
      brands: [
        BoycottBrand('pepsico', 'PepsiCo'),
        BoycottBrand('pepsi', 'Pepsi'),
        BoycottBrand('sabra', 'Sabra'),
        BoycottBrand('lay\'s', 'Lay\'s', aliases: ['lays']),
        BoycottBrand('quaker', 'Quaker'),
        BoycottBrand('doritos', 'Doritos'),
        BoycottBrand('bénénuts', 'Bénénuts', aliases: ['benenuts']),
        BoycottBrand('rockstar', 'Rockstar'),
        BoycottBrand('mountain dew', 'Mountain Dew', aliases: ['montain dew']),
        BoycottBrand('7up', '7UP'),
        BoycottBrand('tropicana', 'Tropicana'),
        BoycottBrand('lipton', 'Lipton'),
      ],
    ),
    BoycottGroup(
      name: 'Nestlé',
      reason:
          'Nestlé a été nommé sponsor international de la guerre par l\'Ukraine pour avoir maintenu ses activités en Russie. Le groupe est aussi mis en cause pour travail des enfants dans ses filières cacao en Afrique de l\'Ouest, et pour avoir remis en question le droit à l\'eau potable en cherchant à privatiser des sources naturelles dans des régions vulnérables. En France, ils ont fait de l\'enfuissement illégal de déchets, menant à des montagnes de plastiques.',
      brands: [
        BoycottBrand('nestlé', 'Nestlé', aliases: ['nestle']),
        BoycottBrand('marmite', 'Marmite'),
        BoycottBrand('garden gourmet', 'Garden Gourmet'),
        BoycottBrand('maggi', 'Maggi'),
        BoycottBrand('nescafé', 'Nescafé'),
        BoycottBrand('nesquik', 'Nesquik', aliases: ['nesquick']),
        BoycottBrand('perrier', 'Perrier'),
        BoycottBrand('vitel', 'Vitel'),
        BoycottBrand('san pellegrino', 'San Pellegrino'),
        BoycottBrand('ferrero', 'Ferrero'),
      ],
    ),
    BoycottGroup(
      name: 'Unilever',
      reason:
          'Unilever a été nommé sponsor international de la guerre par l\'Ukraine. Quand Ben & Jerry\'s a voulu cesser ses ventes dans les colonies israéliennes illégales, Unilever a vendu la marque à son franchisé israélien pour court-circuiter cette décision. Le groupe s\'est aussi opposé à une loi contre le plastique à usage unique, et ses chaînes d\'approvisionnement ont été liées à de la déforestation et du travail des enfants.',
      brands: [
        BoycottBrand('unilever', 'Unilever'),
        BoycottBrand('knorr', 'Knorr'),
        BoycottBrand('maïzena', 'Maïzena', aliases: ['maizena']),
        BoycottBrand('maille', 'Maille'),
        BoycottBrand('amora', 'Amora'),
        BoycottBrand('hellmann\'s', 'Hellmann\'s', aliases: ['hellmanns']),
        BoycottBrand('ben & jerry\'s', 'Ben & Jerry\'s',
            aliases: ['ben & jerrys', 'ben&jerry\'s']),
        BoycottBrand('éléphant', 'Éléphant',
            aliases: ['elephant', 'eléphant']),
        BoycottBrand('the vegetarian butcher', 'The Vegetarian Butcher'),
      ],
    ),
    BoycottGroup(
      name: 'L\'Oréal',
      reason:
          'L\'Oréal dispose de centres de R&D et d\'usines de production en Israël, contribuant directement à son économie. Le groupe vend aussi en Chine où les tests sur les animaux sont légalement obligatoires, ce qui le contraint à cautionner cette pratique malgré ses déclarations contraires.',
      brands: [
        BoycottBrand('l\'oréal', 'L\'Oréal',
            aliases: ['l\'oreal', 'loréal', 'loreal']),
        BoycottBrand('garnier', 'Garnier'),
      ],
    ),
    BoycottGroup(
      name: 'Lidl',
      reason:
          'Lidl a espionné massivement ses employés, collectant des données très personnelles comme leurs cycles menstruels, leur situation financière ou leur vie sentimentale. L\'enseigne ferme délibérément les magasins où des tentatives de syndicalisation émergent, et a été mise en cause pour maltraitance animale dans ses filières d\'approvisionnement. Ils ont aussi été surpris plusieurs fois à mal étiquetter des produits venant d\'Israël pour éviter leur boycott.',
      brands: [
        BoycottBrand('lidl', 'Lidl'),
        BoycottBrand('snack day', 'Snack Day'),
        BoycottBrand('freshona', 'Freshona'),
        BoycottBrand('favorina', 'Favorina'),
        BoycottBrand('deluxe', 'Deluxe'),
        BoycottBrand('cien', 'Cien'),
        BoycottBrand('solevita', 'Solevita'),
        BoycottBrand('sondey', 'Sondey'),
        BoycottBrand('vemondo', 'Vemondo'),
        BoycottBrand('crownfield', 'Crownfield'),
      ],
    ),
    BoycottGroup(
      name: 'Mondelez',
      reason:
          'Mondelez a détruit des dizaines de milliers d\'hectares d\'habitat d\'orangs-outans et continue de recourir au travail des enfants dans ses filières cacao, malgré ses promesses répétées d\'y mettre fin. Le groupe a aussi maintenu ses activités en Russie après l\'invasion de l\'Ukraine, ce qui lui a valu d\'être nommé sponsor international de la guerre.',
      brands: [
        BoycottBrand('mondelez', 'Mondelez'),
        BoycottBrand('oreo', 'Oreo'),
        BoycottBrand('belvita', 'BelVita'),
        BoycottBrand('côte d\'or', 'Côte d\'Or', aliases: ['cote d\'or']),
        BoycottBrand('lu', 'LU'),
        BoycottBrand('belin', 'Belin'),
        BoycottBrand('heudebert', 'Heudebert'),
        BoycottBrand('poulain', 'Poulain'),
        BoycottBrand('sour patch', 'Sour Patch'),
      ],
    ),
    BoycottGroup(
      name: 'Danone',
      reason:
          'Danone a trompé des mères sur les vertus de ses laits infantiles pour booster ses ventes, et versé des pots-de-vin à des sages-femmes pour promouvoir ses formules. Le groupe a aussi été épinglé l\'assèchement de sources naturelles près de ses usines, et pollution plastique dans de nombreux pays.',
      brands: [
        BoycottBrand('danone', 'Danone'),
        BoycottBrand('materne', 'Materne'),
        BoycottBrand('alpro', 'Alpro'),
        BoycottBrand('volvic', 'Volvic'),
        BoycottBrand('evian', 'Evian'),
        BoycottBrand('bledina', 'Blédina'),
      ],
    ),
  ];

  static const List<BoycottOther> others = [
    BoycottOther(
      match: 'starbucks',
      display: 'Starbucks',
      reason:
          'Starbucks pratique l\'évasion fiscale à grande échelle, a privé des agriculteurs éthiopiens de revenus qui leur étaient dus, applique des inégalités salariales selon l\'origine de ses employés et mène des campagnes antisyndicales agressives. La chaîne a par ailleurs collaboré étroitement avec l\'Anti-Defamation League, un lobby pro-israélien influent aux États-Unis.',
    ),
    BoycottOther(
      match: 'la grande épicerie paris',
      display: 'La Grande Épicerie Paris',
      reason:
          'La Grande Épicerie de Paris, filiale du Bon Marché (groupe LVMH), commercialise des produits israéliens et a maintenu ses relations commerciales avec des fournisseurs israéliens malgré les appels au boycott.',
    ),
    BoycottOther(
      match: 'osem',
      display: 'Osem',
      reason:
          'Osem est l\'une des plus grandes entreprises alimentaires d\'Israël, désormais filiale du groupe Nestlé. Elle opère principalement en Israël et contribue directement à son économie.',
    ),
    BoycottOther(
      match: 'ahava',
      display: 'Ahava',
      reason:
          'Ahava est une marque de cosmétiques israélienne dont le site de production est installé dans la colonie illégale de Mitzpe Shalem, en Cisjordanie occupée. Acheter Ahava finance directement une activité implantée sur des terres palestiniennes.',
    ),
    BoycottOther(
      match: 'sodastream',
      display: 'SodaStream',
      reason:
          'SodaStream (désormais propriété de PepsiCo) a longtemps exploité son usine principale dans la colonie israélienne illégale de Mishor Adumim, en Cisjordanie. Malgré un déménagement obtenu sous pression, la marque reste fortement liée à l\'économie israélienne.',
    ),
    BoycottOther(
      match: 'oatly',
      display: 'Oatly',
      reason:
          'Oatly a accepté un investissement de 200 millions de dollars du fonds Blackstone. Le fondateur de Blackstone, Stephen Schwarzman, est un important donateur et soutien de la politique américaine pro-israélienne.',
    ),
    BoycottOther(
      match: 'old el paso',
      display: 'Old El Paso',
      reason:
          'Old El Paso appartient à General Mills, un groupe agroalimentaire américain qui maintient des investissements et des partenariats commerciaux avec des entreprises israéliennes.',
    ),
    BoycottOther(
      match: 'redefine meat',
      display: 'Redefine Meat',
      reason:
          'Redefine Meat est une entreprise de viande végétale fondée et basée en Israël. Acheter ses produits contribue directement à l\'économie israélienne.',
    ),
    BoycottOther(
      match: 'hénaff',
      display: 'Hénaff',
      reason:
          'Hénaff est une entreprise dont le cœur de métier est la viande : pâtés, rillettes et charcuterie. Son modèle économique repose intégralement sur l\'exploitation animale, ce qui le rend fondamentalement incompatible avec les valeurs du véganisme.',
      aliases: ['henaff'],
    ),
    BoycottOther(
      match: 'red bull',
      display: 'Red Bull',
      reason:
          'Red Bull est l\'un des principaux sponsors de la Formule 1, l\'un des sports les plus polluants au monde. La marque maintient aussi des activités et des partenariats en Israël à travers ses événements sportifs.',
      aliases: ['redbull'],
    ),
    BoycottOther(
      match: 'maayane',
      display: 'Maayane',
      reason:
          'Maayane est une marque israélienne commercialisant des produits alimentaires. Acheter ses produits contribue directement à l\'économie israélienne.',
    ),
  ];

  static BoycottMatch? findBrand(String brandInput) {
    final brandList =
        brandInput.split(',').map((e) => e.trim().toLowerCase()).toList();

    for (final brand in brandList) {
      for (final group in groups) {
        for (final b in group.brands) {
          if (b.match == brand || b.aliases.contains(brand)) {
            return BoycottMatch(
              brandDisplay: b.display,
              groupName: group.name,
              reason: group.reason,
            );
          }
        }
      }
      for (final other in others) {
        if (other.match == brand || other.aliases.contains(brand)) {
          return BoycottMatch(
            brandDisplay: other.display,
            groupName: null,
            reason: other.reason,
          );
        }
      }
    }
    return null;
  }
}
