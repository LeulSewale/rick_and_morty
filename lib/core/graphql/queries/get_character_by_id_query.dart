const String getCharacterByIdQuery = '''
query(
  \$id: ID!
) {
  character(id: \$id) {
    id
    name
    status
    species
    type
    gender
    image
    origin { name }
    location { name }
    episode { name episode }
  }
}
'''; 