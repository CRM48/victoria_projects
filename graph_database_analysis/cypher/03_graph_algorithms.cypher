// Requires the Neo4j Graph Data Science (GDS) plugin.
// Run the projections first, before calling the algorithms.

// Project the directed graph
CALL gds.graph.project(
  'Tutorixus', 
  ['Movie', 'Person', 'User', 'Genre', 'Keyword'],
  ['DIRECTED', 'ACTED_IN', 'RATED', 'FOLLOWS', 'PRODUCED', 'HAS_GENRE', 'HAS_KEYWORD', 'WRITER_OF']
);

// Inspect the graph and count its nodes and relationships
CALL gds.graph.list('Tutorixus');

MATCH (m)
RETURN count(m);

MATCH ()-[r]->()
RETURN count(r);

// Count nodes with positive closeness centrality
CALL gds.closeness.stream('Tutorixus')
YIELD nodeId, score
WHERE score > 0
RETURN count(nodeId) AS nodesWithPositiveCloseness;

// Degree centrality for users with scores above three
CALL gds.degree.stream('Tutorixus') YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS n, score
WHERE n:User AND score > 3
RETURN n.username AS Name, score AS `Degree Centrality` ORDER BY Name;

// Project an undirected graph and find people with high betweenness
// Undirected graph:
CALL gds.graph.project(
  'Tutorixus2', 
  ['Movie', 'Person', 'User', 'Genre', 'Keyword'],
  {
    DIRECTED: {orientation: 'UNDIRECTED'},
    ACTED_IN: {orientation: 'UNDIRECTED'},
    RATED: {orientation: 'UNDIRECTED'},
    FOLLOWS: {orientation: 'UNDIRECTED'},
    PRODUCED: {orientation: 'UNDIRECTED'},
    HAS_GENRE: {orientation: 'UNDIRECTED'},
    HAS_KEYWORD: {orientation: 'UNDIRECTED'},
    WRITER_OF: {orientation: 'UNDIRECTED'}
  }
);


CALL gds.betweenness.stream('Tutorixus2') YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS n, score
WHERE n:Person
RETURN n.name AS Name, score AS `Betweenness Centrality` ORDER BY `Betweenness Centrality` DESC;

// Find the movie(s) with the highest betweenness centrality
// and store the score as a node property
CALL gds.betweenness.stream('Tutorixus')
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS n, score
WHERE n:Movie
WITH collect({node: n, score: score}) AS results,
     max(score) AS maxScore
UNWIND results AS result
WITH result.node AS n, result.score AS score, maxScore
WHERE score = maxScore
SET n.topBetweenness = score
RETURN n.title AS Movie, score AS Betweenness;