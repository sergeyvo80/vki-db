[<<< назад](/README.md)

- [Реализация деревьев в SQL: ParentId и Nested Sets](#реализация-деревьев-в-sql-parentid-и-nested-sets)
  - [Метод ParentId (Adjacency List)](#метод-parentid-adjacency-list)
    - [Описание](#описание)
    - [Пример реализации в MS SQL](#пример-реализации-в-ms-sql)
    - [Плюсы](#плюсы)
    - [Минусы](#минусы)
  - [Метод Nested Sets (червь)](#метод-nested-sets-червь)
    - [Описание](#описание-1)
    - [Пример структуры таблицы](#пример-структуры-таблицы)
    - [Пример выборки поддерева узла с Id=5](#пример-выборки-поддерева-узла-с-id5)
    - [Плюсы](#плюсы-1)
    - [Минусы](#минусы-1)
  - [Сравнительная таблица](#сравнительная-таблица)
  - [Рекомендации по выбору](#рекомендации-по-выбору)


# Реализация деревьев в SQL: ParentId и Nested Sets

В SQL для реализации иерархий (деревьев) часто используют два основных подхода: метод с использованием поля ParentId (adjacency list) и метод Nested Sets (червь) с полями tree_left (lft), tree_right (rgt) и level. Оба подхода имеют свои особенности, преимущества и недостатки.

## Метод ParentId (Adjacency List)

### Описание
В таблице хранится поле ParentId, содержащее идентификатор родительского узла. Корневой элемент имеет ParentId = NULL. Через рекурсивный CTE можно легко добиться обхода дерева.

### Пример реализации в MS SQL

```sql
CREATE TABLE Categories (
    Id INT PRIMARY KEY,
    Name NVARCHAR(100),
    ParentId INT NULL,
    FOREIGN KEY (ParentId) REFERENCES Categories(Id)
);

-- Вставка данных
INSERT INTO Categories VALUES
(1, 'Electronics', NULL),
(2, 'Computers', 1),
(3, 'Laptops', 2),
(4, 'Smartphones', 1),
(5, 'Gaming Laptops', 3);

-- Получение всех потомков узла (рекурсивный CTE)
WITH CategoryTree AS (
    SELECT Id, Name, ParentId, 0 as Level
    FROM Categories 
    WHERE Id = 1 -- корневой узел
    
    UNION ALL
    
    SELECT c.Id, c.Name, c.ParentId, ct.Level + 1
    FROM Categories c
    INNER JOIN CategoryTree ct ON c.ParentId = ct.Id
)
SELECT * FROM CategoryTree;

-- Получение пути к корню
WITH CategoryPath AS (
    SELECT Id, Name, ParentId, CAST(Name AS NVARCHAR(MAX)) as Path
    FROM Categories 
    WHERE Id = 5 -- целевой узел
    
    UNION ALL
    
    SELECT c.Id, c.Name, c.ParentId, CAST(c.Name + ' > ' + cp.Path AS NVARCHAR(MAX))
    FROM Categories c
    INNER JOIN CategoryPath cp ON c.Id = cp.ParentId
)
SELECT * FROM CategoryPath;
```

### Плюсы
- Простота реализации - интуитивно понятная структура
- Легкость модификации - добавление/перемещение узлов требует изменения одного поля
- Минимальные данные - хранится только ссылка на родителя
- Гибкость - легко работать с деревьями произвольной глубины


### Минусы
- Сложные запросы - для работы с поддеревьями требуются рекурсивные CTE
- Производительность - рекурсивные запросы могут быть медленными на больших деревьях
- Ограничения глубины - в некоторых СУБД есть ограничения на глубину рекурсии
- Сложность получения уровня - уровень узла вычисляется динамически



---

## Метод Nested Sets (червь)

### Описание
Каждому узлу присваиваются два числовых поля (tree_left и tree_right), которые отражают порядок обхода дерева в глубину. Также можно хранить уровень узла (level). Таким образом все поддерево одного узла можно получить одним диапазонным запросом.

### Пример структуры таблицы
| Id | Name | tree_left | tree_right | level |
|----|------|-----------|------------|-------|

### Пример выборки поддерева узла с Id=5

``` sql
CREATE TABLE CategoriesNested (
    Id INT PRIMARY KEY,
    Name NVARCHAR(100),
    TreeLeft INT NOT NULL,
    TreeRight INT NOT NULL,
    Level INT NOT NULL
);

-- Вставка данных (ручное управление границами)
INSERT INTO CategoriesNested VALUES
(1, 'Electronics', 1, 10, 0),
(2, 'Computers', 2, 7, 1),
(3, 'Laptops', 3, 6, 2),
(4, 'Smartphones', 8, 9, 1),
(5, 'Gaming Laptops', 4, 5, 3);

-- Получение всех потомков узла
SELECT descendant.*
FROM CategoriesNested node
JOIN CategoriesNested descendant 
    ON descendant.TreeLeft BETWEEN node.TreeLeft AND node.TreeRight
WHERE node.Id = 1
ORDER BY descendant.TreeLeft;

-- Получение пути к корню
SELECT ancestor.*
FROM CategoriesNested node
JOIN CategoriesNested ancestor 
    ON node.TreeLeft BETWEEN ancestor.TreeLeft AND ancestor.TreeRight
WHERE node.Id = 5
ORDER BY ancestor.TreeLeft;

-- Получение непосредственных детей
SELECT child.*
FROM CategoriesNested parent
JOIN CategoriesNested child 
    ON child.TreeLeft BETWEEN parent.TreeLeft AND parent.TreeRight
WHERE parent.Id = 2 
    AND child.Level = parent.Level + 1;

-- Подсчет количества потомков
SELECT (TreeRight - TreeLeft - 1) / 2 as DescendantsCount
FROM CategoriesNested 
WHERE Id = 1;
```

### Плюсы
- Высокая производительность - быстрые запросы на получение поддеревьев
- Простота агрегации - легко выполнять статистические запросы
- Отсутствие рекурсии - все операции через BETWEEN
- Легкое определение уровня - уровень хранится явно

### Минусы

- Сложность модификации - вставка/удаление узлов требует пересчета границ
- Риск нарушения целостности - легко испортить структуру при ошибках
- Блокировки - операции модификации могут блокировать большие части таблицы
- Сложность реализации - требуется управление границами при изменениях



## Сравнительная таблица

| Критерий                 | ParentId (Adjacency List)              | Nested Sets (Червь)                   |
|--------------------------|--------------------------------------|-------------------------------------|
| Структура данных         | Простая (id, ParentId)                | Сложная (id, tree_left, tree_right, level) |
| Получение поддерева      | Рекурсивный запрос, медленнее         | Диапазонный запрос, быстрее          |
| Частота обновлений       | Легко выполнять вставки и удаления    | Обновление множества строк при изменении |
| Сложность реализации     | Низкая                              | Высокая                            |
| Поддержка целостности    | Простой внешний ключ                  | Нет прямой поддержки внешних ключей |
| Масштабируемость         | Ограничена глубиной рекурсии         | Хорошо масштабируется при чтении    |


## Рекомендации по выбору

Используйте ParentId когда:
- Дерево часто модифицируется
- Глубина дерева невелика
- Частые операции вставки/удаления
- Простота реализации важнее производительности

Используйте Nested Sets когда:
- Дерево редко меняется, но часто читается
- Нужны быстрые запросы для больших поддеревьев
- Требуется агрегация по поддеревьям
- Можно организовать пакетное обновление структуры

В MS SQL Server также можно рассмотреть использование hierarchyid - встроенного типа данных для работы с иерархиями, который сочетает преимущества обоих подходов.
