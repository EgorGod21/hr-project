-- Создание схемы "dm_ira"
CREATE SCHEMA IF NOT EXISTS dm_ira;

--Создание таблицы "сотрудники_дар"
CREATE TABLE IF NOT EXISTS dm_ira.сотрудники_дар (
	"id_сотрудника" integer PRIMARY KEY,
	Фамилия text NULL,
	Имя text NULL,
	Роль text NOT NULL
);

--Создание таблицы "уровни_знаний"
CREATE TABLE IF NOT EXISTS dm_ira.уровни_знаний (
	id_уровня integer PRIMARY KEY,
	Название text NOT NULL
);

--Создание таблицы "навыки"
CREATE TABLE IF NOT EXISTS dm_ira.навыки (
	id_навыка integer PRIMARY KEY,
	Название text NOT NULL
);

--Создание таблицы "группы_навыков"
CREATE TABLE IF NOT EXISTS dm_ira.группы_навыков (
	"id_группы" integer PRIMARY KEY,
	"Группа навыков" text NOT NULL
);

--Создание таблицы "группы_навыков_и_уровень_знаний_со"
CREATE TABLE IF NOT EXISTS dm_ira.группы_навыков_и_уровень_знаний_со (
    id SERIAL PRIMARY KEY,
	"User ID" integer NOT NULL,
	"Группы навыков" integer NOT NULL,
	"Навыки" integer NOT NULL,
	"Дата изм." TIMESTAMP,
	дата date NOT NULL,
	"Уровень знаний" integer NOT NULL,
	FOREIGN KEY ("Группы навыков") REFERENCES dm_ira.группы_навыков ("id_группы"),
	FOREIGN KEY ("User ID") REFERENCES dm_ira.сотрудники_дар ("id_сотрудника"),
	FOREIGN KEY ("Навыки") REFERENCES dm_ira.навыки (id_навыка),
	FOREIGN KEY ("Уровень знаний") REFERENCES dm_ira.уровни_знаний (id_уровня)
);
