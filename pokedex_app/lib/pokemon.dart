class Pokemon {
  final String name;
  final int spriteId;
  final List<int> typeIds;
  int level;
  final List<String> moves;

  Pokemon({
    required this.name,
    required this.spriteId,
    required this.typeIds,
    required this.level,
    required this.moves,
  });

  String get spriteUrl {
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$spriteId.png';
  }

  List<String> get tipoNomes {
    const typeMap = {
      1: 'Normal',
      2: 'Fighting',
      3: 'Flying',
      4: 'Poison',
      5: 'Ground',
      6: 'Rock',
      7: 'Bug',
      8: 'Ghost',
      9: 'Steel',
      10: 'Fire',
      11: 'Water',
      12: 'Grass',
      13: 'Electric',
      14: 'Psychic',
      15: 'Ice',
      16: 'Dragon',
      17: 'Dark',
      18: 'Fairy',
    };
    
    final List<String> result = [];
    for (int typeId in typeIds) {
      if (typeMap.containsKey(typeId)) {
        result.add(typeMap[typeId]!);
      }
    }
    return result;
  }
}