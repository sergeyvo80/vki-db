[<<< назад](/README.md)

# Приложение


## ORM (Object-Relational Mapping)
Это технология, которая создает "мост" между объектно-ориентированным миром вашего кода (например, на Python, Java, C#) и реляционным миром базы данных (таблицы, строки, столбцы).

Грубо говоря, ORM позволяет вам работать с данными из базы так, как будто это обычные объекты в вашем языке программирования, а не SQL-запросы.


## Что такое Entity Framework простыми словами?
EF ORM — это "мост" между вашими C# классами и реляционной базой данных. Вместо того чтобы писать SQL-запросы вручную, вы работаете с обычными C# объектами, а EF автоматически преобразует эти операции в SQL-запросы.

## 1. Создать приложение
- Visual Studio 2022
- .net 8
- WPF

## 2. Установить пакеты
Выбрать версии 8.0.22
- Microsoft.EntityFrameworkCore 8.0.22
- Microsoft.EntityFrameworkCore.SqlServer 8.0.22
- Microsoft.EntityFrameworkCore.Tools 8.0.22

## 3. Добавьте connection string в App.config
````
<configuration>
    <connectionStrings>
        <add name="SchoolContext"
             connectionString="Data Source=DBSRV\OV2025;Initial Catalog=ВашаБД;Integrated Security=True;MultipleActiveResultSets=True"
             providerName="System.Data.SqlClient" />
    </connectionStrings>
</configuration>
````
## 4. Подключение к БД
Меню -> Средства -> Подключиться к базе данных, (БД которая была создана по ER диаграмме)

## 5. Сгенерировать контекст и модели
Меню -> Средства -> Диспетчер пакетов NuGet -> Консоль диспетчера пакетов

В командной сроке выполнить
````
Scaffold-DbContext "Data Source=DBSRV\OV2025;Initial Catalog=Ваша БД;Integrated Security=True;Trust Server Certificate=True" Microsoft.EntityFrameworkCore.SqlServer -OutputDir Models -Force
````

## 6. Создать грид с данными и фильтром

### 6.1 MainWindow.xaml пример
````
<Window x:Class="YourApp.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation&quot;
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml&quot;
        Title="Список студентов" Height="450" Width="800">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Заголовок -->
        <TextBlock Grid.Row="0" Text="Список студентов" FontSize="20" FontWeight="Bold"
                   HorizontalAlignment="Center" Margin="10"/>

        <!-- DataGrid для отображения студентов -->
        <DataGrid x:Name="studentsDataGrid" Grid.Row="1" Margin="10" AutoGenerateColumns="False"
                  CanUserAddRows="False" IsReadOnly="True">
            <DataGrid.Columns>
                <DataGridTextColumn Header="ID" Binding="{Binding StudentId}" Width="50"/>
                <DataGridTextColumn Header="Имя" Binding="{Binding FirstName}" Width="120"/>
                <DataGridTextColumn Header="Фамилия" Binding="{Binding LastName}" Width="120"/>
                <DataGridTextColumn Header="Email" Binding="{Binding Email}" Width="200"/>
                <DataGridTextColumn Header="Группа" Binding="{Binding Group.GroupName}" Width="100"/>
                <DataGridTextColumn Header="Дата регистрации" Binding="{Binding CreatedDate, StringFormat=dd.MM.yyyy}" Width="120"/>
            </DataGrid.Columns>
        </DataGrid>

        <!-- Панель кнопок -->
        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" Margin="10">
            <Button x:Name="btnRefresh" Content="Обновить" Click="BtnRefresh_Click" Margin="5" Padding="10,5"/>
            <Button x:Name="btnAddStudent" Content="Добавить студента" Click="BtnAddStudent_Click" Margin="5" Padding="10,5"/>
        </StackPanel>
    </Grid>
</Window>
````

### 6.2 MainWindow.xaml.css пример

````
using System;
using System.Data.Entity;
using System.Linq;
using System.Windows;

public partial class MainWindow : Window
{
    private AppDbContext _context;

    public MainWindow()
    {
        InitializeComponent();
        _context = new AppDbContext();
        LoadStudents();
    }

    // Загрузка студентов из базы данных
    private void LoadStudents()
    {
        try
        {
            // Загружаем студентов вместе с информацией о группах
            var students = _context.Students
                .Include(s => s.Group)  // Важно: включаем связанные данные о группе
                .OrderBy(s => s.LastName)
                .ThenBy(s => s.FirstName)
                .ToList();

            studentsDataGrid.ItemsSource = students;
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Ошибка при загрузке данных: {ex.Message}", "Ошибка", 
                          MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    // Обновление данных
    private void BtnRefresh_Click(object sender, RoutedEventArgs e)
    {
        LoadStudents();
    }

    // Добавление нового студента (пример)
    private void BtnAddStudent_Click(object sender, RoutedEventArgs e)
    {
        try
        {
            // Пример добавления тестового студента
            var newStudent = new Student
            {
                FirstName = "Новый",
                LastName = "Студент",
                Email = "new.student@email.com",
                GroupId = 1, // ID существующей группы
                CreatedDate = DateTime.Now
            };

            _context.Students.Add(newStudent);
            _context.SaveChanges();
            
            MessageBox.Show("Студент добавлен успешно!", "Успех", 
                          MessageBoxButton.OK, MessageBoxImage.Information);
            
            LoadStudents(); // Обновляем список
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Ошибка при добавлении студента: {ex.Message}", "Ошибка", 
                          MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    // Обработчик двойного клика по студенту
    private void StudentsDataGrid_MouseDoubleClick(object sender, System.Windows.Input.MouseButtonEventArgs e)
    {
        if (studentsDataGrid.SelectedItem is Student selectedStudent)
        {
            MessageBox.Show($"Выбран студент: {selectedStudent.FirstName} {selectedStudent.LastName}\n" +
                          $"Группа: {selectedStudent.Group?.GroupName}\n" +
                          $"Email: {selectedStudent.Email}", 
                          "Информация о студенте");
        }
    }

    // Освобождение ресурсов при закрытии окна
    protected override void OnClosed(EventArgs e)
    {
        _context?.Dispose();
        base.OnClosed(e);
    }
}
````