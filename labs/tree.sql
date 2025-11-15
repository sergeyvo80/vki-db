-- CREATE TABLE tree (
--   id INT IDENTITY (1, 1) NOT NULL,
--   name VARCHAR(255),
--   tree_left INT NULL,
--   tree_right INT NULL,
--   tree_level INT NULL,
-- );

-- TRUNCATE TABLE tree;

-- INSERT INTO tree (name, tree_left, tree_right, tree_level)
-- VALUES
-- ('A', 1, 18, 0),
-- ('C', 2, 11, 1),
-- ('G', 3, 4, 2),
-- ('F', 5, 10, 2),
-- ('H', 6, 7, 3),
-- ('K', 8, 9, 3),
-- ('B', 12, 17, 1),
-- ('D', 13, 14, 2),
-- ('E', 15, 16, 2);

SELECT
  REPLICATE(' - ', tree_level) + name AS name_with_indent,
  tree_left,
  tree_right
FROM 
  tree 
ORDER BY tree_left;
