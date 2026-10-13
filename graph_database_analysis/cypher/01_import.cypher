// Run once on an empty database. Copy all CSVs to Neo4j import directory.
// Execute using Neo4j Browser, one statement at a time.
CREATE CONSTRAINT genre_id IF NOT EXISTS FOR (g:Genre) REQUIRE  g.id IS UNIQUE;
LOAD CSV WITH HEADERS FROM "file:///genre_node.csv" AS r FIELDTERMINATOR ';'
CREATE (g:Genre {
  id: toInteger(r.`id:ID(Genre)`),
  name: r.name
});
CREATE CONSTRAINT keyword_id IF NOT EXISTS FOR (k:Keyword) REQUIRE  k.id IS UNIQUE;
LOAD CSV WITH HEADERS FROM "file:///keyword_node.csv" AS r FIELDTERMINATOR ';'
CREATE (k:Keyword {
  id: toInteger(r.`id:ID(Keyword)`),
  name: r.name
});
CREATE CONSTRAINT movie_id IF NOT EXISTS FOR (m:Movie) REQUIRE  m.id IS UNIQUE;
LOAD CSV WITH HEADERS FROM "file:///movie_node.csv" AS r FIELDTERMINATOR ';'
CREATE (m:Movie {
  id: toInteger(r.`id:ID(Movie)`),
  title: r.title,
  tagline: r.tagline,
  summary: r.summary,
  poster_image: r.poster_image,
  duration: toInteger(r.`duration:int`),
  rated: r.rated
});
CREATE CONSTRAINT person_id IF NOT EXISTS FOR (p:Person) REQUIRE  p.id IS UNIQUE;
LOAD CSV WITH HEADERS FROM "file:///person_node.csv" AS r FIELDTERMINATOR ';'
CREATE (p:Person {
  id: toInteger(r.`id:ID(Person)`),
  name: r.name,
  born: toInteger(r.`born:int`),
  poster_image: r.poster_image
});
LOAD CSV WITH HEADERS FROM "file:///has_genre_rels.csv" AS r FIELDTERMINATOR ';'
MATCH (m:Movie {id: toInteger(r.`:START_ID(Movie)`)}), (g:Genre {id: toInteger(r.`:END_ID(Genre)`)})
CREATE (m)-[:HAS_GENRE]->(g);
LOAD CSV WITH HEADERS FROM "file:///has_keyword_rels.csv" AS r FIELDTERMINATOR ';'
MATCH (m:Movie {id: toInteger(r.`:START_ID(Movie)`)}), (k:Keyword {id: toInteger(r.`:END_ID(Keyword)`)})
CREATE (m)-[:HAS_KEYWORD]->(k);
LOAD CSV WITH HEADERS FROM "file:///writer_of_rels.csv" AS r FIELDTERMINATOR ';'
MATCH (p:Person {id: toInteger(r.`:START_ID(Person)`)}), (m:Movie {id: toInteger(r.`:END_ID(Movie)`)})
CREATE (p)-[:WRITER_OF]->(m);
LOAD CSV WITH HEADERS FROM "file:///produced_rels.csv" AS r FIELDTERMINATOR ';'
MATCH (p:Person {id: toInteger(r.`:START_ID(Person)`)}), (m:Movie {id: toInteger(r.`:END_ID(Movie)`)})
CREATE (p)-[:PRODUCED]->(m);
LOAD CSV WITH HEADERS FROM "file:///directed_rels.csv" AS r FIELDTERMINATOR ';'
MATCH (p:Person {id: toInteger(r.`:START_ID(Person)`)}), (m:Movie {id: toInteger(r.`:END_ID(Movie)`)})
CREATE (p)-[:DIRECTED]->(m);
LOAD CSV WITH HEADERS FROM "file:///acted_in_rels.csv" AS r FIELDTERMINATOR ';'
MATCH (p:Person {id: toInteger(r.`:START_ID(Person)`)}), (m:Movie {id: toInteger(r.`:END_ID(Movie)`)})
CREATE (p)-[:ACTED_IN{role:split(r.role, '/')}]->(m);
CREATE CONSTRAINT user_id IF NOT EXISTS FOR (u:User) REQUIRE u.id IS UNIQUE;
LOAD CSV WITH HEADERS FROM 'file:///ratings.csv' AS line
MATCH (m:Movie {id:toInteger(line.movie_id)})
MERGE (u:User {id:line.user_id, username:line.user_username}) // user ids are strings
MERGE (u)-[r:RATED]->(m)
SET r.rating = toInteger(line.rating)
RETURN m.title, r.rating, u.username;
