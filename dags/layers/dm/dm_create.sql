-- Создание схемы "dds_ira"
CREATE SCHEMA IF NOT EXISTS dm_ira;

--Создание таблицы "базы_данных"
CREATE TABLE IF NOT EXISTS dm_ira.базы_данных (
	id integer PRIMARY KEY,
	название text NOT NULL
);

--Создание таблицы "инструменты"
CREATE TABLE IF NOT EXISTS dm_ira.инструменты (
	id integer PRIMARY KEY,
	название text NOT NULL
);

--Создание таблицы "платформы"
CREATE TABLE IF NOT EXISTS dm_ira.платформы (
	id integer PRIMARY KEY,
	название text NOT NULL
);

--Создание таблицы "сотрудники_дар"
CREATE TABLE IF NOT EXISTS dm_ira.сотрудники_дар (
	id integer PRIMARY KEY,
	фамилия text,
	имя text,
	Роль text
);

--Создание таблицы "среды_разработки"
CREATE TABLE IF NOT EXISTS dm_ira.среды_разработки (
	id integer PRIMARY KEY,
	название text NOT NULL
);

--Создание таблицы "технологии"
CREATE TABLE IF NOT EXISTS dm_ira.технологии (
	id integer PRIMARY KEY,
	название text NOT NULL
);

--Создание таблицы "типы_систем"
CREATE TABLE IF NOT EXISTS dm_ira.типы_систем (
	id integer PRIMARY KEY,
	название text NOT NULL
);

--Создание таблицы "уровни_знаний"
CREATE TABLE IF NOT EXISTS dm_ira.уровни_знаний (
	id integer PRIMARY KEY,
	название text NOT NULL
);

--Создание таблицы "фреймворки"
CREATE TABLE IF NOT EXISTS dm_ira.фреймворки (
	id integer PRIMARY KEY,
	название text NOT NULL
);

--Создание таблицы "языки_программирования"
CREATE TABLE IF NOT EXISTS dm_ira.языки_программирования (
	id integer PRIMARY KEY,
	название text NOT NULL
);

--Создание таблицы "базы_данных_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS dm_ira.базы_данных_и_уровень_знаний_сотру (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	"Базы данных" integer NOT NULL,
	дата date,
	"Уровень знаний" integer NOT NULL,
	FOREIGN KEY ("Базы данных") REFERENCES dds_ira.базы_данных (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "инструменты_и_уровень_знаний_сотр"
CREATE TABLE IF NOT EXISTS dm_ira.инструменты_и_уровень_знаний_сотр (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	дата date,
	инструменты integer NOT NULL,
	"Уровень знаний" integer NOT NULL,
	FOREIGN KEY (инструменты) REFERENCES dds_ira.инструменты (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "платформы_и_уровень_знаний_сотруд"
CREATE TABLE IF NOT EXISTS dm_ira.платформы_и_уровень_знаний_сотруд (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	дата date,
	платформы integer NOT NULL,
	"Уровень знаний" integer NOT NULL,
	FOREIGN KEY (платформы) REFERENCES dds_ira.платформы (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "среды_разработки_и_уровень_знаний_"
CREATE TABLE IF NOT EXISTS dm_ira.среды_разработки_и_уровень_знаний_ (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	дата date,
	"Среды разработки" integer NOT NULL,
	"Уровень знаний" integer NOT NULL,
	FOREIGN KEY ("Среды разработки") REFERENCES dds_ira.среды_разработки (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "технологии_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS dm_ira.технологии_и_уровень_знаний_сотру (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	дата date,
	технологии integer NOT NULL,
	"Уровень знаний" integer NOT NULL,
	FOREIGN KEY (технологии) REFERENCES dds_ira.технологии (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "типы_систем_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS dm_ira.типы_систем_и_уровень_знаний_сотру (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	дата date,
	"Типы систем" integer NOT NULL,
	"Уровень знаний" integer NOT NULL,
	FOREIGN KEY ("Типы систем") REFERENCES dds_ira.типы_систем (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "фреймворки_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS dm_ira.фреймворки_и_уровень_знаний_сотру (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	дата date,
	"Уровень знаний" integer NOT NULL,
	фреймворки integer NOT NULL,
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY (фреймворки) REFERENCES dds_ira.фреймворки (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "языки_программирования_и_уровень"
CREATE TABLE IF NOT EXISTS dm_ira.языки_программирования_и_уровень (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	дата date,
	"Уровень знаний" integer NOT NULL,
	"Языки программирования" integer NOT NULL,
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY ("Языки программирования") REFERENCES dds_ira.языки_программирования (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);
