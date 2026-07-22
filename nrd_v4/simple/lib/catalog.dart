class RevivalCategory {
  const RevivalCategory(this.id, this.name, this.slug);
  final int id;
  final String name;
  final String slug;
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug};
  factory RevivalCategory.fromJson(Map<String, dynamic> j) => RevivalCategory((j['id'] as num?)?.toInt() ?? 0, '${j['name'] ?? ''}', '${j['slug'] ?? ''}');
}

const defaultCategories = <RevivalCategory>[
  RevivalCategory(1,'Sunday Services','sunday-services'), RevivalCategory(2,'Joint Sunday Services','joint-sunday-services'),
  RevivalCategory(3,'Public Crusades','public-crusades'), RevivalCategory(4,'Joint Public Crusades','joint-public-crusades'),
  RevivalCategory(5,'Door-to-Door Evangelism','door-to-door-evangelism'), RevivalCategory(6,'One-to-One Evangelism','one-to-one-evangelism'),
  RevivalCategory(7,'Lunch Hour Services','lunch-hour-services'), RevivalCategory(8,'Midweek Home Fellowships','midweek-home-fellowships'),
  RevivalCategory(9,'Projector Shows','projector-shows'), RevivalCategory(10,'Worship Extravaganza','worship-extravaganza'),
  RevivalCategory(11,'Majirani Revivals','majirani-revivals'), RevivalCategory(12,'Processions','processions'), RevivalCategory(13,'Keshas','keshas'),
  RevivalCategory(14,'Workshops','workshops'), RevivalCategory(15,'Youth Conferences','youth-conferences'),
  RevivalCategory(16,'Women Conferences','women-conferences'), RevivalCategory(17,'Men’s Conferences','mens-conferences'),
  RevivalCategory(18,'Leaders Conferences','leaders-conferences'), RevivalCategory(19,'Widows Conferences','widows-conferences'),
  RevivalCategory(20,'Family Revival Conferences','family-revival-conferences'),
  RevivalCategory(21,'Repentance & Wailing Meetings','repentance-and-wailing-meetings'), RevivalCategory(22,'Baptism','baptism'),
  RevivalCategory(23,'Hospital Ministries','hospital-ministries'), RevivalCategory(24,'Prisons Ministries','prisons-ministries'),
  RevivalCategory(25,'Street Families Outreaches','street-families-outreaches'),
  RevivalCategory(26,'Community Mercy Ministries','community-mercy-ministries'),
  RevivalCategory(27,'Schools & Colleges Ministries','schools-and-colleges-ministries'),
  RevivalCategory(28,'Professionals Fellowships','professionals-fellowships'),
  RevivalCategory(29,'Disciplined Forces Ministries','disciplined-forces-ministries'),
];

const provinces = <String, List<String>>{
  'Central':['Nyandarua','Nyeri','Kirinyaga',"Murang'a",'Kiambu'],
  'Coast':['Mombasa','Kwale','Kilifi','Tana River','Lamu','Taita-Taveta'],
  'Eastern':['Marsabit','Isiolo','Meru','Tharaka-Nithi','Embu','Kitui','Machakos','Makueni'],
  'Nairobi':['Nairobi'], 'North Eastern':['Garissa','Wajir','Mandera'],
  'Nyanza':['Siaya','Kisumu','Homa Bay','Migori','Kisii','Nyamira'],
  'Rift Valley':['Turkana','West Pokot','Samburu','Trans Nzoia','Uasin Gishu','Elgeyo-Marakwet','Nandi','Baringo','Laikipia','Nakuru','Narok','Kajiado','Kericho','Bomet'],
  'Western':['Kakamega','Vihiga','Bungoma','Busia'],
};

String formatRegion(String input) {
  var value = input.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (RegExp(r'\bregion\b', caseSensitive: false).hasMatch(value)) throw const FormatException('Enter only the region name. “Region” is added automatically.');
  if (!RegExp(r"^[A-Za-z][A-Za-z '\-]*$").hasMatch(value)) throw const FormatException('Use letters, spaces, apostrophes or hyphens only.');
  value = value.split(' ').map((w) => w.split('-').map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}').join('-')).join(' ');
  return '$value Region';
}
