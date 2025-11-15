
-- DROP TABLE analysis_orders;

-- CREATE TABLE analysis(
--   id INT IDENTITY (1, 1) NOT NULL,
--   name VARCHAR(255),
--   cost INT NULL,
--   price INT NULL,
--   CONSTRAINT PK_analysis_ID PRIMARY KEY CLUSTERED (id)
-- );

-- CREATE TABLE analysis_group (
--   id INT IDENTITY (1, 1) NOT NULL,
--   name VARCHAR(255),
--   temp INT NULL,
--   CONSTRAINT PK_AnalysisGroup_ID PRIMARY KEY CLUSTERED (id)
-- );

-- CREATE TABLE analysis_orders (
--   id INT IDENTITY (1, 1) NOT NULL,
--   datetime DATETIME,
--   analysis INT NULL,
--   CONSTRAINT PK_AnalysisOrders_ID PRIMARY KEY CLUSTERED (id)
-- );

-- ALTER TABLE analysis_orders
-- ADD CONSTRAINT FK_analysisOrders_order
-- FOREIGN KEY (analysis)
-- REFERENCES analysis (id);


-- analysis - таблица анализов
-- id
-- name — название анализа;
-- cost — себестоимость анализа;
-- price — розничная цена анализа;

-- analysis_group — группа анализов.
-- id
-- name — название группы;
-- temp — температурный режим хранения.

-- analysis_orders - таблица заказов
-- id
-- datetime — дата и время заказа;
-- analysis — ID анализа.
