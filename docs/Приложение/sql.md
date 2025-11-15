[<<< назад](/README.md)

- [Выполнения собственных SQL запросов в WPF приложении с Entity Framework](#выполнения-собственных-sql-запросов-в-wpf-приложении-с-entity-framework)
  - [Способ 1: Использование DbContext.Database.SqlQuery (EF6)](#способ-1-использование-dbcontextdatabasesqlquery-ef6)
  - [Способ 2: Выполнение произвольных SQL команд](#способ-2-выполнение-произвольных-sql-команд)
  - [Способ 3: Сложные запросы с параметрами](#способ-3-сложные-запросы-с-параметрами)
  - [Способ 4: Хранимые процедуры](#способ-4-хранимые-процедуры)
  - [Способ 5: Прямое использование SqlConnection](#способ-5-прямое-использование-sqlconnection)
    - [Пример использования в WPF приложении](#пример-использования-в-wpf-приложении)
  - [Способ 6: Динамический запрос от пользователя](#способ-6-динамический-запрос-от-пользователя)
    - [Важные замечания:](#важные-замечания)


# Выполнения собственных SQL запросов в WPF приложении с Entity Framework

## Способ 1: Использование DbContext.Database.SqlQuery<T> (EF6)
Для выполнения SELECT запросов:

```csharp
// Получение студентов с дополнительными полями
public List<StudentInfo> GetStudentInfo()
{
    string sql = @"
        SELECT 
            s.StudentId,
            s.FirstName,
            s.LastName,
            s.Email,
            g.GroupName,
            COUNT(*) OVER() as TotalCount
        FROM Student s
        INNER JOIN [Group] g ON s.GroupId = g.GroupId
        ORDER BY s.LastName, s.FirstName";

    var students = _context.Database.SqlQuery<StudentInfo>(sql).ToList();
    return students;
}

// Класс для результатов запроса
public class StudentInfo
{
    public int StudentId { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string Email { get; set; }
    public string GroupName { get; set; }
    public int TotalCount { get; set; }
}
```

## Способ 2: Выполнение произвольных SQL команд
Для INSERT, UPDATE, DELETE:

```csharp
// Добавление студента через SQL
public void AddStudentWithSql(string firstName, string lastName, string email, int groupId)
{
    string sql = @"
        INSERT INTO Student (FirstName, LastName, Email, GroupId, CreatedDate)
        VALUES ({0}, {1}, {2}, {3}, {4})";
    
    _context.Database.ExecuteSqlCommand(
        sql, firstName, lastName, email, groupId, DateTime.Now);
}

// Обновление email студента
public void UpdateStudentEmail(int studentId, string newEmail)
{
    string sql = "UPDATE Student SET Email = {0} WHERE StudentId = {1}";
    _context.Database.ExecuteSqlCommand(sql, newEmail, studentId);
}

// Удаление студента
public void DeleteStudent(int studentId)
{
    string sql = "DELETE FROM Student WHERE StudentId = {0}";
    _context.Database.ExecuteSqlCommand(sql, studentId);
}
```

## Способ 3: Сложные запросы с параметрами
```csharp
// Поиск студентов по группе с статистикой
public List<StudentStats> GetStudentStatistics(int? groupId = null)
{
    string sql = @"
        SELECT 
            g.GroupName,
            s.FirstName,
            s.LastName,
            s.Email,
            DATEDIFF(day, s.CreatedDate, GETDATE()) as DaysSinceRegistration,
            (SELECT COUNT(*) FROM Student s2 WHERE s2.GroupId = g.GroupId) as StudentsInGroup
        FROM Student s
        INNER JOIN [Group] g ON s.GroupId = g.GroupId
        WHERE (@groupId IS NULL OR s.GroupId = @groupId)
        ORDER BY g.GroupName, s.LastName";

    var parameters = new SqlParameter("@groupId", groupId ?? (object)DBNull.Value);
    
    return _context.Database.SqlQuery<StudentStats>(sql, parameters).ToList();
}

public class StudentStats
{
    public string GroupName { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string Email { get; set; }
    public int DaysSinceRegistration { get; set; }
    public int StudentsInGroup { get; set; }
}
```

## Способ 4: Хранимые процедуры
Если у вас есть хранимые процедуры в БД:

```csharp
// Вызов хранимой процедуры
public List<Student> GetStudentsByGroup(string groupName)
{
    var result = _context.Database.SqlQuery<Student>(
        "EXEC GetStudentsByGroup @GroupName",
        new SqlParameter("@GroupName", groupName)
    ).ToList();
    
    return result;
}
```

## Способ 5: Прямое использование SqlConnection
```csharp
using System.Data;
using System.Data.SqlClient;

public DataTable ExecuteCustomQuery(string sqlQuery, params SqlParameter[] parameters)
{
    var connectionString = _context.Database.Connection.ConnectionString;
    
    using (var connection = new SqlConnection(connectionString))
    using (var command = new SqlCommand(sqlQuery, connection))
    {
        command.Parameters.AddRange(parameters);
        
        var dataTable = new DataTable();
        var adapter = new SqlDataAdapter(command);
        
        connection.Open();
        adapter.Fill(dataTable);
        
        return dataTable;
    }
}
```

### Пример использования в WPF приложении
Добавьте кнопку и обработчик в XAML:

```xml
<Button Content="Выполнить кастомный запрос" Click="BtnCustomQuery_Click" Margin="5"/>
```

В коде:

```csharp
private void BtnCustomQuery_Click(object sender, RoutedEventArgs e)
{
    try
    {
        // Пример 1: Сложный SELECT
        var topStudents = _context.Database.SqlQuery<TopStudent>(@"
            SELECT TOP 10 
                s.StudentId,
                s.FirstName + ' ' + s.LastName as FullName,
                g.GroupName,
                s.CreatedDate
            FROM Student s
            INNER JOIN [Group] g ON s.GroupId = g.GroupId
            ORDER BY s.CreatedDate DESC").ToList();

        // Показать результат
        MessageBox.Show($"Найдено студентов: {topStudents.Count}");

        // Пример 2: Обновление через SQL
        int affectedRows = _context.Database.ExecuteSqlCommand(@"
            UPDATE Student 
            SET Email = 'updated@email.com' 
            WHERE GroupId = 1");
            
        MessageBox.Show($"Обновлено записей: {affectedRows}");
        
        // Обновить DataGrid
        LoadStudents();
    }
    catch (Exception ex)
    {
        MessageBox.Show($"Ошибка: {ex.Message}", "Ошибка SQL", 
                      MessageBoxButton.OK, MessageBoxImage.Error);
    }
}

public class TopStudent
{
    public int StudentId { get; set; }
    public string FullName { get; set; }
    public string GroupName { get; set; }
    public DateTime CreatedDate { get; set; }
}
```

## Способ 6: Динамический запрос от пользователя

```csharp
private void ExecuteUserQuery()
{
    var queryWindow = new QueryWindow(); // Ваше окно для ввода SQL
    if (queryWindow.ShowDialog() == true)
    {
        string userQuery = queryWindow.SqlQuery;
        
        try
        {
            // Для SELECT запросов
            if (userQuery.Trim().ToUpper().StartsWith("SELECT"))
            {
                var results = _context.Database.SqlQuery<dynamic>(userQuery).ToList();
                // Показать результаты в отдельном окне или DataGrid
                ShowQueryResults(results);
            }
            else // Для INSERT, UPDATE, DELETE
            {
                int affected = _context.Database.ExecuteSqlCommand(userQuery);
                MessageBox.Show($"Выполнено. Затронуто строк: {affected}");
                LoadStudents(); // Обновить данные
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Ошибка выполнения запроса: {ex.Message}");
        }
    }
}
```

### Важные замечания:

- Безопасность: Всегда используйте параметризованные запросы для защиты от SQL-инъекций
- Производительность: Для сложных отчетов используйте прямые SQL запросы
- Транзакции: Для групповых операций используйте транзакции
- Валидация: Проверяйте SQL запросы перед выполнением

```csharp
// Пример с транзакцией
using (var transaction = _context.Database.BeginTransaction())
{
    try
    {
        _context.Database.ExecuteSqlCommand("DELETE FROM Student WHERE GroupId = 1");
        _context.Database.ExecuteSqlCommand("UPDATE [Group] SET GroupName = 'Новая' WHERE GroupId = 1");
        
        transaction.Commit();
    }
    catch
    {
        transaction.Rollback();
        throw;
    }
}
```

Таким образом вы можете выполнять любые SQL запросы в вашем WPF приложении!

