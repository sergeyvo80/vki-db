[<<< назад](/README.md)

- [ADO.NET](#adonet)
  - [1. Что такое ADO.NET?](#1-что-такое-adonet)
  - [2. Основные компоненты ADO.NET](#2-основные-компоненты-adonet)
  - [3. Основные классы ADO.NET](#3-основные-классы-adonet)
  - [4. Практические примеры использования в WPF](#4-практические-примеры-использования-в-wpf)
  - [5. Сравнение ADO.NET и Entity Framework](#5-сравнение-adonet-и-entity-framework)
  - [6. Современный подход: ADO.NET Core](#6-современный-подход-adonet-core)
  - [7. Когда использовать ADO.NET?](#7-когда-использовать-adonet)
  - [8. Преимущества ADO.NET](#8-преимущества-adonet)


# ADO.NET
Технология доступа к данным в .NET Framework, которая предоставляет набор классов для работы с базами данных и другими источниками данных.

Основные понятия ADO.NET
## 1. Что такое ADO.NET?
ActiveX Data Objects for .NET

Часть .NET Framework для работы с данными

Позволяет соединяться с БД, выполнять запросы, обрабатывать результаты

Альтернатива Entity Framework (более низкоуровневая)

## 2. Основные компоненты ADO.NET
Connected Model (Подключенная модель):
```csharp
using System.Data.SqlClient;

// Создание подключения
SqlConnection connection = new SqlConnection(connectionString);

// Создание команды
SqlCommand command = new SqlCommand("SELECT * FROM Students", connection);

// Открытие подключения и выполнение запроса
connection.Open();
SqlDataReader reader = command.ExecuteReader();

// Чтение данных
while (reader.Read())
{
    Console.WriteLine(reader["FirstName"] + " " + reader["LastName"]);
}

// Закрытие подключения
reader.Close();
connection.Close();
```

Disconnected Model (Отключенная модель):

```csharp
// DataAdapter и DataSet
SqlDataAdapter adapter = new SqlDataAdapter("SELECT * FROM Students", connection);
DataSet dataSet = new DataSet();

// Заполнение DataSet
adapter.Fill(dataSet, "Students");

// Работа с данными без подключения к БД
DataTable studentsTable = dataSet.Tables["Students"];
foreach (DataRow row in studentsTable.Rows)
{
    Console.WriteLine(row["FirstName"] + " " + row["LastName"]);
}
```

## 3. Основные классы ADO.NET
SqlConnection - подключение к БД
```csharp
string connectionString = "Data Source=.;Initial Catalog=vki-lms;Integrated Security=True";
using (SqlConnection connection = new SqlConnection(connectionString))
{
    connection.Open();
    // Работа с БД
}
```

SqlCommand - выполнение команд

```csharp
using (SqlCommand command = new SqlCommand())
{
    command.Connection = connection;
    command.CommandText = "INSERT INTO Students (FirstName, LastName) VALUES (@FirstName, @LastName)";
    command.Parameters.AddWithValue("@FirstName", "Иван");
    command.Parameters.AddWithValue("@LastName", "Петров");
    command.ExecuteNonQuery();
}
SqlDataReader - чтение данных (только вперед)

```csharp
using (SqlDataReader reader = command.ExecuteReader())
{
    while (reader.Read())
    {
        int id = reader.GetInt32(0);
        string name = reader.GetString(1);
    }
}
```

SqlDataAdapter и DataSet - отключенная работа

```csharp
SqlDataAdapter adapter = new SqlDataAdapter("SELECT * FROM Students", connection);
DataSet dataSet = new DataSet();
adapter.Fill(dataSet, "Students");
```

## 4. Практические примеры использования в WPF
Пример 1: Получение данных и привязка к DataGrid
```csharp
public DataTable GetStudentsDataTable()
{
    string connectionString = "Data Source=.;Initial Catalog=vki-lms;Integrated Security=True";
    string sql = "SELECT * FROM Students";
    
    using (SqlConnection connection = new SqlConnection(connectionString))
    {
        SqlDataAdapter adapter = new SqlDataAdapter(sql, connection);
        DataTable dataTable = new DataTable();
        adapter.Fill(dataTable);
        return dataTable;
    }
}

// Использование в WPF
dataGrid.ItemsSource = GetStudentsDataTable().DefaultView;
```

Пример 2: Выполнение хранимой процедуры
```csharp
public void CallStoredProcedure(int studentId)
{
    using (SqlConnection connection = new SqlConnection(connectionString))
    {
        SqlCommand command = new SqlCommand("GetStudentDetails", connection);
        command.CommandType = CommandType.StoredProcedure;
        command.Parameters.AddWithValue("@StudentId", studentId);
        
        connection.Open();
        SqlDataReader reader = command.ExecuteReader();
        
        // Обработка результатов
    }
}
```

Пример 3: Транзакции

```csharp
using (SqlConnection connection = new SqlConnection(connectionString))
{
    connection.Open();
    SqlTransaction transaction = connection.BeginTransaction();
    
    try
    {
        using (SqlCommand command = new SqlCommand())
        {
            command.Connection = connection;
            command.Transaction = transaction;
            command.CommandText = "UPDATE Students SET GroupId = 2 WHERE StudentId = 1";
            command.ExecuteNonQuery();
            
            command.CommandText = "DELETE FROM Students WHERE StudentId = 5";
            command.ExecuteNonQuery();
            
            transaction.Commit();
        }
    }
    catch
    {
        transaction.Rollback();
        throw;
    }
}
```
## 5. Сравнение ADO.NET и Entity Framework


| Критерий                 | ParentId (Adjacency List)              | Nested Sets (Червь)                   |
|--------------------------|--------------------------------------|-------------------------------------|
| Структура данных         | Простая (id, ParentId)                | Сложная (id, tree_left, tree_right, level) |
| Получение поддерева      | Рекурсивный запрос, медленнее         | Диапазонный запрос, быстрее          |
| Частота обновлений       | Легко выполнять вставки и удаления    | Обновление множества строк при изменении |
| Сложность реализации     | Низкая                              | Высокая                            |
| Поддержка целостности    | Простой внешний ключ                  | Нет прямой поддержки внешних ключей |
| Масштабируемость         | Ограничена глубиной рекурсии         | Хорошо масштабируется при чтении    |



| Параметр         | ADO.NET         | Entity Framework |
|--------------------------|--------------------------------------|-------------------------------------|
| Уровень абстракции         | Низкий (близко к SQL)                | Высокий (ORM) |
| Производительность         | Выше                | Немного ниже |
| Производительность        | Выше        | Немного ниже |
| Простота использования        | Сложнее        | Проще
Безопасность | Ручное управление параметрами        | Автоматическая защита от инъекций |
| Поддержка LINQ	Нет	Да | Миграции БД	Ручные |Автоматические |

## 6. Современный подход: ADO.NET Core
Для .NET Core/.NET 5+ используйте пространство имен:

```csharp
using Microsoft.Data.SqlClient; // Вместо System.Data.SqlClient

string connectionString = "Data Source=.;Initial Catalog=vki-lms;Integrated Security=True";
using (var connection = new SqlConnection(connectionString))
{
    await connection.OpenAsync();
    // Работа с БД
}
```

## 7. Когда использовать ADO.NET?
- Высокопроизводительные приложения
- Сложные SQL запросы и хранимые процедуры
- Работа с большими объемами данных
- Когда нужен полный контроль над SQL запросами

Легаси системы

## 8. Преимущества ADO.NET
- Высокая производительность
- Полный контроль над SQL запросами
- Гибкость в работе с данными
- Поддержка сложных сценариев
- Меньший overhead

ADO.NET — это фундаментальная технология для работы с данными в .NET, которая до сих пор широко используется, особенно в enterprise-приложениях где важна производительность и контроль над запросами.

