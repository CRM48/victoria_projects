// Run after importing the movie dataset.
// The follow and user-creation queries modify the graph.

// Other films directed by a director of Inception
MATCH (p:Person)-[:DIRECTED]->(m:Movie) 
WHERE EXISTS { (p)-[:DIRECTED]->(:Movie {title: "Inception"}) } 
AND NOT m.title = "Inception" 
RETURN m.title AS Title;

// Actors in films directed by a director of Inception
MATCH (director:Person)-[:DIRECTED]->(m:Movie)<-[:ACTED_IN]-(actor:Person) 
WHERE EXISTS { (director)-[:DIRECTED]->(:Movie {title: "Inception"}) } 
RETURN m.title AS Title, collect(actor.name) AS `List of Actors`;

// Director film counts, with names starting M through Y
MATCH (director:Person)-[:DIRECTED]->(m:Movie) 
WHERE toUpper(substring(director.name, 0, 1)) >="M" 
AND toUpper(substring(director.name, 0, 1)) <= "Y" 
RETURN director.name AS `Directors-Name`, count(m) AS `Number of Movies` 
ORDER BY `Directors-Name`;

// Average ratings and review counts for selected movies
MATCH (:User)-[r:RATED]->(m:Movie) 
WHERE m.title IN ["Cloud Atlas", "Goodfellas", "Forrest Gump", "The Lorax", "The Usual Suspects"] 
RETURN m.title AS Title, avg(r.rating) AS `Average Rating`, count(r) AS `Number of Reviews` 
ORDER BY `Average Rating`;

// Create a follow relationship between Aaron and James
MATCH (aaron:User {username: "Aaron"}) 
MATCH (james:User {username: "James"}) 
MERGE (aaron)-[f:FOLLOWS {year: 2023}]->(james) 
RETURN f, aaron, james;

// Create a user with ratings and connect Aaron to that user
MATCH (m1:Movie {title: "Fargo"}) 
MATCH (m2:Movie {title: "The Godfather"}) 
MATCH (m3:Movie {title: "3 Days to Kill"}) 
MATCH (m4:Movie {title: "Frozen"}) 
WITH m1, m2, m3, m4 
MERGE (curtis:User {username: "Curtis"}) 
MERGE (curtis)-[r1:RATED {rating: 5}]->(m1)
MERGE (curtis)-[r2:RATED {rating: 5}]->(m2)
MERGE (curtis)-[r3:RATED {rating: 4}]->(m3) 
MERGE (curtis)-[r4:RATED {rating: 4}]->(m4) 
WITH curtis 
MATCH (aaron:User {username: "Aaron"}) 
MERGE (aaron)-[:FOLLOWS]->(curtis);

// Ratings from the users followed by Aaron
MATCH (aaron:User {username: "Aaron"})
MATCH (aaron)-[:FOLLOWS]->(friends:User)-[r:RATED]->(m:Movie)
RETURN m.title AS MOVIES, friends.username AS `Followed User`, r.rating AS rating;
