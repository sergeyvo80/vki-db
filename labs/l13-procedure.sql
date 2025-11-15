-- Active: 1760755267015@@178.49.34.8@1433@vki

----лаба13
-- 1 Напишите хранимую процедуру для вывода информации о сервере, о базе данных, 
-- о текущем пользователе, о текущем времени, и вызовите ее.
CREATE PROC СерверБдПользовательВремя
AS
BEGIN
	SELECT
   @@Servername AS Сервер,
   @@Version AS [Версия СУБД],
   Db_Name() AS [База данных],
   User AS [Пользователь базы данных],
   System_User AS [Системный пользователь],
   CAST(GETDATE() AS TIME) AS [Текущее время]
END

EXECUTE СерверБдПользовательВремя;

-- 2 Напишите хранимую процедуру, которая выводит данные всех стран.
CREATE PROC ДанныеВсехСтран
AS
BEGIN
	SELECT * FROM Страны
END

EXECUTE ДанныеВсехСтран;

-- 3 Напишите хранимую процедуру, которая выводит список стран, 
-- кроме заданной части света, и вызовите ее.
CREATE PROC СписокСтранКроме
@Конт AS VARCHAR(50)
AS
BEGIN
	SELECT Название,Столица,Площадь,Население
   FROM Страны
   WHERE Континент != @Конт
END

EXECUTE СписокСтранКроме 'Азия';

-- 4 Напишите хранимую процедуру, которая выводит список стран, 
-- население которых находится в заданном интервале, и вызовите ее.
CREATE PROC НаселениеВИнтервале
@A AS FLOAT,
@B AS FLOAT
AS
BEGIN
	SELECT Название,Столица,Площадь,Население,Континент 
   FROM Страны 
   WHERE Население BETWEEN @A AND @B
END

EXECUTE НаселениеВИнтервале 300000, 1400000;

-- 5 Напишите хранимую процедуру, которая возвращает количество стран, у которых в названии 
-- отсутствует заданная буква, и вызовите ее.
CREATE PROC БезБуквы
@Буква AS CHAR(1),
@Количество AS INT OUTPUT
AS
BEGIN
	SELECT @Количество = COUNT(*) 
   FROM Страны 
   WHERE CHARINDEX(@Буква, Название) = 0
END

DECLARE @К AS INT
DECLARE @Б AS CHAR(1)
SET @Б = 'у'
EXECUTE БезБуквы @Б, @К OUTPUT
SELECT @К AS [Количество стран]
GO

-- 6 Напишите хранимую процедуру для вывода пяти стран с наибольшим населением 
-- в заданной части света, и вызовите ее. Если часть света не указана, выбрать Африку.
CREATE PROC ПятьСтранПоЧастиСвета
@Конт AS VARCHAR(50) = 'Африка'
AS
BEGIN
	SELECT TOP 5 Название,Столица,Площадь,Население,Континент 
   FROM Страны 
   WHERE Континент = @Конт 
   ORDER BY Население DESC
END

EXECUTE ПятьСтранПоЧастиСвета DEFAULT

-- 7 Напишите хранимую процедуру, которая создает таблицу «Страны_<первая буква вашей фамилии>»,
-- и заполняет ее странами, названия которых начинаются с первой буквой вашей фамилии.
CREATE OR ALTER PROC Табл_Страны_Н
AS
BEGIN
	SELECT Название,Столица,Площадь,Население,Континент
   INTO Страны_О2
   FROM Страны
   WHERE LEFT(Название, 1) = 'О'
END

EXECUTE Табл_Страны_Н

-- 8 Напишите хранимую процедуру, которая удаляет таблицу, которую вы создали 
-- в предыдущем задании и возвращает количество удаленных строк.
CREATE OR ALTER PROC УдалитьСтраны_Н
AS
BEGIN
	DECLARE @K AS INT
	SELECT @K = COUNT(*)
   FROM Страны_О2
	DROP TABLE Страны_02
   RETURN @K
END

DECLARE @C AS INT
EXECUTE @C = УдалитьСтраны_Н SELECT @C AS [Количество строк в удаленной таблице]
GO

-- 9 Напишите хранимую процедуру, принимающую число и возвращающую количество цифр 
-- в нем через параметр OUTPUT.
CREATE PROC КоличествоЦифр
   @Число INT,
   @количество_цифр INT OUTPUT
AS
BEGIN
   SET @количество_цифр = LEN(CAST(@Число AS VARCHAR));
END

DECLARE @Ч AS INT
DECLARE @К AS INT
SET @Ч = 23
EXECUTE КоличествоЦифр @Ч, @К OUTPUT SELECT @К
GO


-- 10 Напишите хранимую процедуру AddRightDigit, добавляющую к целому положительному числу K 
-- справа цифру D (D – входной параметр целого типа, лежащий в диапазоне
-- [0..9], K – параметр целого типа, являющийся одновременно входным и выходным).
CREATE PROCEDURE AddRightDigit
   @K INT OUTPUT,
   @D INT
AS
BEGIN
   IF @D < 0 OR @D > 9
   BEGIN 
		RETURN
   END

   IF @K <= 0
   BEGIN
       RETURN
   END

   SET @K = @K * 10 + @D
END
GO

DECLARE @K_input INT = 123
DECLARE @D_input INT = 4
EXECUTE AddRightDigit @K = @K_input OUTPUT, @D = @D_input SELECT @K_input
GO

-- 11 Напишите хранимую процедуру InvDigit, меняющую порядок следования цифр 
-- целого положительного числа K на обратный 
-- (K – параметр целого типа, являющийся одновременно входным и выходным).
CREATE PROCEDURE InvDigit
   @K INT OUTPUT
AS
BEGIN
--   SELECT @Число = CAST(  REVERSE(CAST(@Число AS VARCHAR))  AS INT)
   DECLARE @Orig_K INT = @K;
   DECLARE @Revers_K INT = 0;
   DECLARE @Digit INT;

   WHILE @Orig_K > 0
   BEGIN
       SET @Digit = @Orig_K % 10
       SET @Revers_K = @Revers_K * 10 + @Digit
       SET @Orig_K = @Orig_K / 10
   END

   SET @K = @Revers_K
END

DECLARE @K_input INT = 123
EXECUTE InvDigit @K = @K_input OUTPUT SELECT @K_input
GO


-- 12 Напишите хранимую процедуру Swap, меняющую содержимое переменных X и Y 
-- (X и Y – вещественные параметры, являющиеся одновременно входными и выходными).
CREATE PROCEDURE Swap
   @X INT OUTPUT,
   @Y INT OUTPUT
AS
BEGIN
   DECLARE @temp INT

-- SELECT 
-- 	@n3 = @n1
-- 	,@n1 = @n2
-- 	,@n2 = @n3

   SET @temp = @X
   SET @X = @Y
   SET @Y = @temp
END

DECLARE @X_in INT = 123
DECLARE @Y_in INT = 34
EXECUTE Swap @X = @X_in OUTPUT, @Y = @Y_in OUTPUT SELECT @X_in AS X, @Y_in AS Y
GO


-- 13 Напишите хранимую процедуру SortInc, меняющую содержимое переменных A, B, C, 
-- таким образом, чтобы их значения оказались упорядоченными по возрастанию 
-- (A, B, C – вещественные параметры, являющиеся одновременно входными и выходными).
CREATE OR ALTER PROCEDURE SortInc
   @A FLOAT OUTPUT,
   @B FLOAT OUTPUT,
   @C FLOAT OUTPUT
AS
BEGIN
   DECLARE @temp FLOAT

   IF @A > @B
   BEGIN
       SET @temp = @A
       SET @A = @B
       SET @B = @temp
   END

   IF @B > @C
   BEGIN
       SET @temp = @B
       SET @B = @C
       SET @C = @temp
   END

   IF @A > @B
   BEGIN
       SET @temp = @A
       SET @A = @B
       SET @B = @temp
   END
END
GO

DECLARE @A_in FLOAT = 25.5
DECLARE @B_in FLOAT = 32.1
DECLARE @C_in FLOAT = 219.8

EXECUTE SortInc @A = @A_in OUTPUT, @B = @B_in OUTPUT, @C = @C_in OUTPUT SELECT @A_in, @B_in, @C_in
GO


-- 14 Напишите хранимую процедуру DigitCountSum, находящую количество C цифр 
-- целого положительного числа K, а также их сумму S 
-- (K – входной, C, S – выходные параметры целого типа).
CREATE PROCEDURE DigitCountSum (
   @K INT,
   @C INT OUTPUT,
   @S INT OUTPUT
)
AS
BEGIN
   SET @C = 0;
   SET @S = 0;

   IF @K < 0
   BEGIN
       RETURN;
   END

   IF @K = 0
   BEGIN
       SET @C = 1;
       SET @S = 0;
       RETURN;
   END

   WHILE @K > 0
   BEGIN
       SET @C = @C + 1;
       SET @S = @S + (@K % 10);
       SET @K = @K / 10;
   END
END
GO

DECLARE @K_in INT = 253
DECLARE @C_in INT = 2
DECLARE @S_in INT
EXECUTE DigitCountSum @K = @K_in, @C = @C_in OUTPUT, @S = @S_in OUTPUT SELECT @C_in, @S_in AS сумма
GO

--15 Напишите код, который удаляет все хранимые процедуры, вами созданные.
--Drop proc IF EXISTS СерверБдПользовательВремя,ДанныеВсехСтран,СписокСтранКроме,НаселениеВИнтервале,БезБуквы,ПятьСтранПоЧастиСвета,Табл_Страны_Н,УдалитьСтраны_Н,КоличествоЦифр,AddRightDigit,InvDigit,Swap,SortInc,DigitCountSum
