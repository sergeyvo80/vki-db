[<<< назад](/README.md)

# Несколько способов увидеть SQL запросы, которые формирует Entity Framework

## Способ 1: Включение логгирования SQL в коде (EF6)
Добавьте в конструктор MainWindow или AppDbContext:

```csharp
public MainWindow()
{
    InitializeComponent();
    _context = new AppDbContext();
    
    // Включение логгирования SQL в Output Window
    _context.Database.Log = sql => Debug.WriteLine(sql);
    
    LoadGroups();
    LoadStudents();
}
```

Или в AppDbContext:

```csharp
public AppDbContext() : base("name=DefaultConnection")
{
    this.Database.Log = sql => Debug.WriteLine($"EF SQL: {sql}");
}
```

## Способ 2: Просмотр в Output Window
После включения логгирования, все SQL запросы будут выводиться в Output Window Visual Studio:

View → Output или Ctrl+Alt+O

В выводе вы увидите что-то подобное:

```sql
EF SQL: SELECT 
    [Extent1].[GroupId] AS [GroupId], 
    [Extent1].[GroupName] AS [GroupName], 
    [Extent1].[CreatedDate] AS [CreatedDate]
    FROM [dbo].[Group] AS [Extent1]
    ORDER BY [Extent1].[GroupName] ASC
```

## Способ 3: Использование SQL Server Profiler
Запустите SQL Server Profiler

Подключитесь к вашему SQL Server

Запустите новый trace

Выполните ваше приложение

Вы увидите все выполняемые запросы

## Способ 4: Расширенное логгирование с таймингом
```csharp
public void EnableDetailedLogging()
{
    _context.Database.Log = sql =>
    {
        Debug.WriteLine($"=== EF SQL QUERY ===");
        Debug.WriteLine($"SQL: {sql}");
        Debug.WriteLine($"Time: {DateTime.Now:HH:mm:ss.fff}");
        Debug.WriteLine($"=====================");
    };
}
```

## Способ 5: Создание метода для анализа запросов
```csharp
private void LoadGroupsWithLogging()
{
    // Очистка предыдущего лога
    Debug.WriteLine("=== START LoadGroups ===");
    
    var stopwatch = System.Diagnostics.Stopwatch.StartNew();
    
    try
    {
        var groups = _context.Groups
            .OrderBy(g => g.GroupName)
            .ToList();
            
        stopwatch.Stop();
        
        Debug.WriteLine($"Query executed in: {stopwatch.ElapsedMilliseconds}ms");
        Debug.WriteLine($"Groups loaded: {groups.Count}");
        Debug.WriteLine("=== END LoadGroups ===");
    }
    catch (Exception ex)
    {
        Debug.WriteLine($"ERROR: {ex.Message}");
    }
}
```

## Способ 6: Перехватчик для Entity Framework (более продвинутый)
Создайте класс-перехватчик:

```csharp
public class EfInterceptor : IDbCommandInterceptor
{
    public void NonQueryExecuting(
        DbCommand command, DbCommandInterceptionContext<int> interceptionContext)
    {
        LogInfo("NonQuery Executing", command.CommandText);
    }

    public void NonQueryExecuted(
        DbCommand command, DbCommandInterceptionContext<int> interceptionContext)
    {
        LogInfo("NonQuery Executed", command.CommandText);
    }

    public void ReaderExecuting(
        DbCommand command, DbCommandInterceptionContext<DbDataReader> interceptionContext)
    {
        LogInfo("Reader Executing", command.CommandText);
    }

    public void ReaderExecuted(
        DbCommand command, DbCommandInterceptionContext<DbDataReader> interceptionContext)
    {
        LogInfo("Reader Executed", command.CommandText);
    }

    public void ScalarExecuting(
        DbCommand command, DbCommandInterceptionContext<object> interceptionContext)
    {
        LogInfo("Scalar Executing", command.CommandText);
    }

    public void ScalarExecuted(
        DbCommand command, DbCommandInterceptionContext<object> interceptionContext)
    {
        LogInfo("Scalar Executed", command.CommandText);
    }

    private void LogInfo(string method, string commandText)
    {
        Debug.WriteLine($"Intercepted on: {method}");
        Debug.WriteLine($"Command Text: {commandText}");
    }
}
```

Зарегистрируйте его в AppDbContext:

```csharp
static AppDbContext()
{
    DbInterception.Add(new EfInterceptor());
}
```

## Способ 7: Для Entity Framework Core
Если вы используете EF Core, добавьте в AppDbContext:

```csharp
protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
{
    optionsBuilder.UseSqlServer("YourConnectionString")
                  .LogTo(Console.WriteLine, LogLevel.Information);
}
```

## Способ 8: Просмотр через IntelliTrace (Visual Studio Enterprise)
Debug → IntelliTrace → Open IntelliTrace Events

Ищите события ADO.NET

Пример того, что вы увидите для LoadGroups:
```sql
-- Запрос для LoadGroups
SELECT 
    [Extent1].[GroupId] AS [GroupId], 
    [Extent1].[GroupName] AS [GroupName], 
    [Extent1].[CreatedDate] AS [CreatedDate]
FROM [dbo].[Group] AS [Extent1]
ORDER BY [Extent1].[GroupName] ASC

-- Запрос для LoadStudents (с JOIN)
SELECT 
    [Extent1].[StudentId] AS [StudentId], 
    [Extent1].[FirstName] AS [FirstName], 
    [Extent1].[LastName] AS [LastName], 
    [Extent1].[Email] AS [Email], 
    [Extent1].[GroupId] AS [GroupId], 
    [Extent1].[CreatedDate] AS [CreatedDate], 
    [Extent2].[GroupId] AS [GroupId1], 
    [Extent2].[GroupName] AS [GroupName], 
    [Extent2].[CreatedDate] AS [CreatedDate1]
FROM  [dbo].[Student] AS [Extent1]
INNER JOIN [dbo].[Group] AS [Extent2] ON [Extent1].[GroupId] = [Extent2].[GroupId]
ORDER BY [Extent1].[LastName] ASC, [Extent1].[FirstName] ASC
```

Рекомендуемый простой способ:
Добавьте эту строку в конструктор MainWindow:

```csharp
_context.Database.Log = sql => Debug.WriteLine(sql);
```

Затем откройте Output Window (View → Output) и запустите приложение. Вы увидите все SQL запросы, которые генерирует Entity Framework для ваших методов LoadGroups() и LoadStudents().