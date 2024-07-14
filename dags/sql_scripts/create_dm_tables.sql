CREATE SCHEMA IF NOT EXISTS dm_egor;

--1 сотрудники_дар 
CREATE TABLE IF NOT EXISTS dm_egor.сотрудники_дар (
	id INT PRIMARY KEY,
	активность TEXT,
	фамилия TEXT,
	имя TEXT,
	должность TEXT NOT NULL,
	цфо TEXT NOT NULL
);

--2 инструменты
CREATE TABLE IF NOT EXISTS dm_egor.инструменты (
	id INT PRIMARY KEY,
	название TEXT NOT NULL
);

--3 уровни_знаний
CREATE TABLE IF NOT EXISTS dm_egor.уровни_знаний (
	id INT PRIMARY KEY,
	название TEXT NOT NULL
);


--4 инструменты_и_уровень_знаний_сотр
CREATE TABLE IF NOT EXISTS dm_egor.инструменты_и_уровень_знаний_сотр (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT,
	"Дата изм." TIMESTAMP,
	дата DATE NULL,
	инструменты INT,
	"Уровень знаний" INT,
	FOREIGN KEY (инструменты) REFERENCES dm_egor.инструменты (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dm_egor.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dm_egor.сотрудники_дар (id)
);

--5 базы_данных
CREATE TABLE IF NOT EXISTS dm_egor.базы_данных (
	id INT PRIMARY KEY,
	название TEXT NOT NULL
);

--6 базы_данных_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS dm_egor.базы_данных_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT,
	"Дата изм." TIMESTAMP,
	дата DATE,
	"Базы данных" INT,
	"Уровень знаний" INT,
	FOREIGN KEY ("Базы данных") REFERENCES dm_egor.базы_данных (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dm_egor.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dm_egor.сотрудники_дар (id)
);

--19 платформы
CREATE TABLE IF NOT EXISTS dm_egor.платформы (
	id INT PRIMARY KEY,
	название TEXT NOT NULL
);

--20 платформы_и_уровень_знаний_сотруд
CREATE TABLE IF NOT EXISTS dm_egor.платформы_и_уровень_знаний_сотруд (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT,
	"Дата изменения" TIMESTAMP,
	дата DATE,
	платформы INT,
	"Уровень знаний" INT,
	FOREIGN KEY (платформы) REFERENCES dm_egor.платформы (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dm_egor.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dm_egor.сотрудники_дар (id)
);

--21 среды_разработки
CREATE TABLE IF NOT EXISTS dm_egor.среды_разработки (
	id INT PRIMARY KEY,
	название TEXT NOT NULL
);

--22 среды_разработки_и_уровень_знаний_
CREATE TABLE IF NOT EXISTS dm_egor.среды_разработки_и_уровень_знаний_ (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT,
	"Дата изменения" TIMESTAMP,
	дата DATE,
	"Среды разработки" INT,
	"Уровень знаний" INT,
	FOREIGN KEY ("Среды разработки") REFERENCES dm_egor.среды_разработки (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dm_egor.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dm_egor.сотрудники_дар (id)
);

--23 типы_систем
CREATE TABLE IF NOT EXISTS dm_egor.типы_систем (
	id INT PRIMARY KEY,
	название TEXT NOT NULL
);

--24 типы_систем_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS dm_egor.типы_систем_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT,
	"Дата изменения" TIMESTAMP,
	дата DATE,
	"Типы систем" INT,
	"Уровень знаний" INT,
	FOREIGN KEY ("Типы систем") REFERENCES dm_egor.типы_систем (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dm_egor.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dm_egor.сотрудники_дар (id)
);

--25 фреймворки
CREATE TABLE IF NOT EXISTS dm_egor.фреймворки (
	id INT PRIMARY KEY,
	название TEXT NOT NULL
);

--26 фреймворки_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS dm_egor.фреймворки_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT,
	"Дата изменения" TIMESTAMP,
	дата DATE,
	фреймворки INT,
	"Уровень знаний" INT,
	FOREIGN KEY ("Уровень знаний") REFERENCES dm_egor.уровни_знаний (id),
	FOREIGN KEY (фреймворки) REFERENCES dm_egor.фреймворки (id),
	FOREIGN KEY ("User ID") REFERENCES dm_egor.сотрудники_дар (id)
);

--27 языки_программирования 
CREATE TABLE IF NOT EXISTS dm_egor.языки_программирования (
	id INT PRIMARY KEY,
	название TEXT NOT NULL
);

--28 языки_программирования_и_уровень
CREATE TABLE IF NOT EXISTS dm_egor.языки_программирования_и_уровень (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT,
	"Дата изменения" TIMESTAMP,
	дата DATE,
	"Языки программирования" INT,
	"Уровень знаний" INT,
	FOREIGN KEY ("Уровень знаний") REFERENCES dm_egor.уровни_знаний (id),
	FOREIGN KEY ("Языки программирования") REFERENCES dm_egor.языки_программирования (id),
	FOREIGN KEY ("User ID") REFERENCES dm_egor.сотрудники_дар (id)
);

--29 технологии
CREATE TABLE IF NOT EXISTS dm_egor.технологии (
	id INT PRIMARY KEY,
	название TEXT NOT NULL
);

--30 технологии_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS dm_egor.технологии_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT,
	"Дата изменения" TIMESTAMP,
	дата DATE NULL,
	технологии INT,
	"Уровень знаний" INT,
	FOREIGN KEY (технологии) REFERENCES dm_egor.технологии (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dm_egor.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dm_egor.сотрудники_дар (id)
);