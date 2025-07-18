
const String getCharactersQuery = '''
query(\$page: Int!) {
  characters(page: \$page) {
    results {
      id
      name
      image
    }
  }
}
''';
