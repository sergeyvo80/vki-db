[<<< назад](/README.md)
- [LINQ (Language Integrated Query)](#linq-language-integrated-query)
  - [Основные понятия LINQ](#основные-понятия-linq)
    - [1. Что такое LINQ?](#1-что-такое-linq)
    - [2. Основные компоненты LINQ](#2-основные-компоненты-linq)
    - [3. Синтаксис LINQ](#3-синтаксис-linq)
    - [4. Основные операции LINQ](#4-основные-операции-linq)
    - [5. Практические примеры в WPF приложении](#5-практические-примеры-в-wpf-приложении)
    - [6. LINQ с Entity Framework](#6-linq-с-entity-framework)
    - [7. Отложенное и немедленное выполнение](#7-отложенное-и-немедленное-выполнение)
    - [8. JOIN операции в LINQ](#8-join-операции-в-linq)
    - [9. Преимущества LINQ](#9-преимущества-linq)
    - [10. Пример комплексного использования в WPF](#10-пример-комплексного-использования-в-wpf)


# LINQ (Language Integrated Query)
Это технология в .NET, которая позволяет писать запросы к данным напрямую в коде C# или VB.NET, используя синтаксис, похожий на SQL.

## Основные понятия LINQ

### 1. Что такое LINQ?
Language Integrated Query — встроенный в язык запрос

Часть .NET Framework начиная с версии 3.5

Позволяет запрашивать данные из различных источников (коллекции, БД, XML, etc.)

Унифицированный синтаксис для работы с разными типами данных

### 2. Основные компоненты LINQ
LINQ Providers:
- LINQ to Objects - запросы к коллекциям в памяти
- LINQ to SQL - запросы к SQL Server БД
- LINQ to Entities - запросы через Entity Framework
- LINQ to XML - запросы к XML документам
- LINQ to DataSet - запросы к DataSet

### 3. Синтаксис LINQ
Method Syntax (синтаксис методов):
```csharp
var students = context.Students
    .Where(s => s.Age > 18)
    .OrderBy(s => s.LastName)
    .Select(s => new { s.FirstName, s.LastName })
    .ToList();
Query Syntax (синтаксис запросов):
csharp
var students = from s in context.Students
               where s.Age > 18
               orderby s.LastName
               select new { s.FirstName, s.LastName };
```

### 4. Основные операции LINQ
Фильтрация (Where):

```csharp
// Студенты старше 18 лет
var adultStudents = students.Where(s => s.Age > 18);

// Студенты из определенной группы
var groupStudents = students.Where(s => s.GroupId == 1);
Проекция (Select):
csharp
// Выбор только имен
var names = students.Select(s => s.FirstName);

// Создание анонимных объектов
var studentInfo = students.Select(s => new 
{ 
    Name = s.FirstName + " " + s.LastName,
    s.Email 
});
Сортировка (OrderBy):
```csharp
// Сортировка по фамилии
var sorted = students.OrderBy(s => s.LastName);

// Сортировка по убыванию
var descSorted = students.OrderByDescending(s => s.Age);

// Множественная сортировка
var multiSorted = students
    .OrderBy(s => s.LastName)
    .ThenBy(s => s.FirstName);
```

Группировка (GroupBy):
```csharp
// Группировка студентов по группам
var studentsByGroup = students.GroupBy(s => s.GroupId);

foreach (var group in studentsByGroup)
{
    Console.WriteLine($"Group ID: {group.Key}");
    foreach (var student in group)
    {
        Console.WriteLine($" - {student.FirstName} {student.LastName}");
    }
}
```

Агрегатные функции:
```csharp
// Количество студентов
int count = students.Count();

// Средний возраст
double avgAge = students.Average(s => s.Age);

// Максимальный возраст
int maxAge = students.Max(s => s.Age);

// Сумма баллов
int totalScore = students.Sum(s => s.Score);
```

### 5. Практические примеры в WPF приложении
Пример 1: Фильтрация и сортировка студентов
```csharp
public void LoadFilteredStudents(string searchText, int? groupId)
{
    var query = _context.Students.AsQueryable();
    
    // Применяем фильтры
    if (!string.IsNullOrEmpty(searchText))
    {
        query = query.Where(s => 
            s.FirstName.Contains(searchText) || 
            s.LastName.Contains(searchText));
    }
    
    if (groupId.HasValue)
    {
        query = query.Where(s => s.GroupId == groupId.Value);
    }
    
    // Сортировка и загрузка
    var students = query
        .Include(s => s.Group)
        .OrderBy(s => s.LastName)
        .ThenBy(s => s.FirstName)
        .ToList();
        
    studentsDataGrid.ItemsSource = students;
}
```

Пример 2: Статистика по группам

```csharp
public void ShowGroupStatistics()
{
    var stats = _context.Groups
        .Select(g => new
        {
            GroupName = g.GroupName,
            StudentCount = g.Students.Count(),
            AverageScore = g.Students.Average(s => s.Score),
            OldestStudent = g.Students.Max(s => s.Age)
        })
        .ToList();
        
    statisticsDataGrid.ItemsSource = stats;
}
```

Пример 3: Поиск с пагинацией

```csharp
public List<Student> GetStudentsPage(int pageNumber, int pageSize, string searchFilter)
{
    var query = _context.Students.AsQueryable();
    
    if (!string.IsNullOrEmpty(searchFilter))
    {
        query = query.Where(s => s.LastName.Contains(searchFilter));
    }
    
    return query
        .OrderBy(s => s.LastName)
        .Skip((pageNumber - 1) * pageSize)
        .Take(pageSize)
        .ToList();
}
```

### 6. LINQ с Entity Framework
Запросы к БД через LINQ:

```csharp
// EF преобразует этот LINQ запрос в SQL
var studentsInGroup = context.Students
    .Where(s => s.Group.GroupName == "ИТ-101")
    .Select(s => new 
    { 
        s.StudentId, 
        FullName = s.FirstName + " " + s.LastName,
        s.Group.GroupName 
    })
    .ToList();
```

SQL который сгенерируется:
```sql
SELECT 
    [s].[StudentId],
    [s].[FirstName] + ' ' + [s].[LastName] AS [FullName],
    [g].[GroupName]
FROM [Students] AS [s]
INNER JOIN [Groups] AS [g] ON [s].[GroupId] = [g].[GroupId]
WHERE [g].[GroupName] = 'ИТ-101'
```

### 7. Отложенное и немедленное выполнение
Отложенное выполнение (Deferred Execution):
```csharp
// Запрос не выполняется сразу
var query = students.Where(s => s.Age > 18);

// Выполняется только при перечислении
foreach (var student in query)  // ← ЗДЕСЬ выполняется запрос
{
    Console.WriteLine(student.Name);
}
Немедленное выполнение (Immediate Execution):
```csharp
// Запрос выполняется сразу
var list = students.Where(s => s.Age > 18).ToList();
var count = students.Count(s => s.Age > 18);
var first = students.First(s => s.Age > 18);
```

### 8. JOIN операции в LINQ
```csharp
// JOIN студентов с группами
var studentGroups = from s in context.Students
                    join g in context.Groups on s.GroupId equals g.GroupId
                    select new 
                    { 
                        s.FirstName, 
                        s.LastName, 
                        g.GroupName 
                    };

// Method syntax
var studentGroups2 = context.Students
    .Join(context.Groups,
          s => s.GroupId,
          g => g.GroupId,
          (s, g) => new { s.FirstName, s.LastName, g.GroupName });
```

### 9. Преимущества LINQ
- Type Safety - проверка типов на этапе компиляции
- IntelliSense - подсказки в Visual Studio
- Унифицированный синтаксис для разных источников данных
- Читаемость кода
- Производительность (особенно с EF)

### 10. Пример комплексного использования в WPF
```csharp
public class StudentService
{
    public List<StudentViewModel> GetStudentReport()
    {
        return _context.Students
            .Include(s => s.Group)
            .Where(s => s.CreatedDate.Year == DateTime.Now.Year)
            .GroupBy(s => s.Group.GroupName)
            .Select(g => new StudentViewModel
            {
                GroupName = g.Key,
                StudentCount = g.Count(),
                AverageAge = g.Average(s => s.Age),
                Students = g.OrderBy(s => s.LastName).ToList()
            })
            .OrderBy(g => g.GroupName)
            .ToList();
    }
}
```

LINQ — это мощный инструмент, который делает работу с данными в C# более выразительной, безопасной и эффективной, особенно в сочетании с Entity Framework в WPF приложениях.

