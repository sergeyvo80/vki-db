[<<< назад](/README.md)

- [Что такое Entity Framework простыми словами?](#что-такое-entity-framework-простыми-словами)
  - [Основные компоненты](#основные-компоненты)
    - [1. DbContext - основной класс для работы с БД](#1-dbcontext---основной-класс-для-работы-с-бд)
    - [2. DbSet - представляет таблицу в БД](#2-dbset---представляет-таблицу-в-бд)
    - [3. Модели (Entity Classes) - C# классы, которые отображаются на таблицы БД](#3-модели-entity-classes---c-классы-которые-отображаются-на-таблицы-бд)
    - [Как это работает на практике](#как-это-работает-на-практике)
  - [1. Database First](#1-database-first)
  - [2. Code First (самый популярный)](#2-code-first-самый-популярный)
    - [Конфигурация моделей](#конфигурация-моделей)
  - [Через атрибуты:](#через-атрибуты)
  - [Через Fluent API (в DbContext):](#через-fluent-api-в-dbcontext)
  - [Миграции - мощный инструмент EF](#миграции---мощный-инструмент-ef)
    - [Создание миграции](#создание-миграции)
    - [Применение миграции к БД](#применение-миграции-к-бд)
    - [Откат миграции](#откат-миграции)
  - [Преимущества Entity Framework](#преимущества-entity-framework)
  - [Недостатки](#недостатки)


# Что такое Entity Framework простыми словами?
EF — это "мост" между вашими C# классами и реляционной базой данных. Вместо того чтобы писать SQL-запросы вручную, вы работаете с обычными C# объектами, а EF автоматически преобразует эти операции в SQL-запросы.


## Основные компоненты
### 1. DbContext - основной класс для работы с БД
```csharp
public class AppDbContext : DbContext
{
    public DbSet<User> Users { get; set; }
    public DbSet<Order> Orders { get; set; }
}
```

### 2. DbSet - представляет таблицу в БД
```csharp
// DbSet в DbContext
public DbSet<Product> Products { get; set; }
```

### 3. Модели (Entity Classes) - C# классы, которые отображаются на таблицы БД
```csharp
public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Email { get; set; }
    public List<Order> Orders { get; set; }
}

public class Order
{
    public int Id { get; set; }
    public DateTime OrderDate { get; set; }
    public int UserId { get; set; }
    public User User { get; set; }
}
```

### Как это работает на практике
Без Entity Framework:
```csharp
// Ручная работа с SQL
var connection = new SqlConnection(connectionString);
var command = new SqlCommand("SELECT * FROM Users WHERE Id = @id", connection);
command.Parameters.AddWithValue("@id", userId);
// ... и т.д. - много шаблонного кода
```

С Entity Framework:
```csharp
// Простая и понятная работа с объектами
using var context = new AppDbContext();

// CREATE
var newUser = new User { Name = "Иван", Email = "ivan@mail.ru" };
context.Users.Add(newUser);
context.SaveChanges();

// READ
var user = context.Users.FirstOrDefault(u => u.Name == "Иван");
var users = context.Users.Where(u => u.Email.Contains("mail.ru")).ToList();

// UPDATE
user.Email = "new_email@mail.ru";
context.SaveChanges();

// DELETE
context.Users.Remove(user);
context.SaveChanges();
Основные подходы работы
```

## 1. Database First
Начинаем с существующей базы данных

EF генерирует C# классы на основе структуры БД

Хорошо для работы с legacy-системами

## 2. Code First (самый популярный)
Начинаем с написания C# классов

EF создает структуру БД на основе этих классов

Современный и гибкий подход

```csharp
// Code First пример
public class Product
{
    public int ProductId { get; set; }
    public string Name { get; set; }
    public decimal Price { get; set; }
}

// Миграция создаст таблицу Products на основе этого класса
```

### Конфигурация моделей
## Через атрибуты:
```csharp
public class User
{
    [Key]
    public int UserId { get; set; }
    
    [Required]
    [MaxLength(100)]
    public string Name { get; set; }
    
    [EmailAddress]
    public string Email { get; set; }
}
```

## Через Fluent API (в DbContext):

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<User>()
        .HasKey(u => u.UserId);
        
    modelBuilder.Entity<User>()
        .Property(u => u.Name)
        .IsRequired()
        .HasMaxLength(100);
        
    modelBuilder.Entity<User>()
        .HasMany(u => u.Orders)
        .WithOne(o => o.User)
        .HasForeignKey(o => o.UserId);
}
```

## Миграции - мощный инструмент EF
Миграции позволяют управлять изменениями схемы БД через код:


### Создание миграции
dotnet ef migrations Add InitialCreate

### Применение миграции к БД
dotnet ef database update

### Откат миграции
dotnet ef database update PreviousMigrationName
Версии Entity Framework
Entity Framework 6 - для .NET Framework

Entity Framework Core - кроссплатформенная версия для .NET Core

## Преимущества Entity Framework
- ✅ Высокая скорость разработки - меньше рутинного SQL кода
- ✅ Безопасность - автоматическая защита от SQL-инъекций
- ✅ Поддержка LINQ - мощный язык запросов прямо в C#
- ✅ Автоматическое отслеживание изменений
- ✅ Миграции - контроль версий схемы БД
- ✅ Кроссплатформенность (EF Core)

## Недостатки
- ❌ Кривая обучения - нужно понимать внутреннее устройство
- ❌ Производительность - в некоторых сложных сценариях ручной SQL может быть быстрее
- ❌ "Магия" - иногда сложно понять, какой SQL сгенерируется

````
public class BlogService
{
    private readonly AppDbContext _context;
    
    public BlogService(AppDbContext context)
    {
        _context = context;
    }
    
    public List<Post> GetRecentPosts(int count)
    {
        return _context.Posts
            .Include(p => p.Author)      // JOIN с таблицей Authors
            .Include(p => p.Comments)    // JOIN с таблицей Comments
            .Where(p => p.PublishedDate >= DateTime.Now.AddDays(-7))
            .OrderByDescending(p => p.PublishedDate)
            .Take(count)
            .ToList();
    }
}
````

Entity Framework — это мощный и зрелый ORM, который значительно упрощает работу с данными в .NET приложениях, позволяя разработчикам сосредоточиться на бизнес-логике, а не на рутинных операциях с базой данных.


