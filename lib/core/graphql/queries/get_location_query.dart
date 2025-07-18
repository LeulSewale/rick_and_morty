
// Locations Query
const String getLocationsQuery = '''
query {
  locations(page: 1) {
    results {
      id
      name
      dimension
      type
    }
  }
}
''';