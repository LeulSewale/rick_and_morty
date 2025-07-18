// Episodes Query
const String getEpisodesQuery = '''
query(\$page: Int!) {
  episodes(page: \$page) {
    info {
      next
    }
    results {
      id
      name
      episode
      air_date
    }
  }
}
''';
