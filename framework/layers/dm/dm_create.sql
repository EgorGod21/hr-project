-- Создание схемы "dm"
CREATE SCHEMA IF NOT EXISTS dm;

--Создание таблицы "сотрудники_дар"
CREATE TABLE IF NOT EXISTS dm.сотрудники_дар (
	id_сотрудника integer PRIMARY KEY,
	Фамилия text NULL,
	Имя text NULL,
	Роль text NOT NULL
);

--Создание таблицы "уровни_знаний"
CREATE TABLE IF NOT EXISTS dm.уровни_знаний (
	id_уровня integer PRIMARY KEY,
	Название text NOT NULL
);

--Создание таблицы "навыки"
CREATE TABLE IF NOT EXISTS dm.навыки (
	id_навыка integer PRIMARY KEY,
	Название text NOT NULL
);

--Создание таблицы "группы_навыков"
CREATE TABLE IF NOT EXISTS dm.группы_навыков (
	id_группы integer PRIMARY KEY,
	Группа_навыков text NOT NULL
);

--Создание таблицы "группы_навыков_и_уровень_знаний_со"
CREATE TABLE IF NOT EXISTS dm.группы_навыков_и_уровень_знаний_со (
    id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	Дата date NOT NULL,
	Группа_навыков integer NOT NULL,
	Навыки integer NOT NULL,
	Уровень_знаний integer NOT NULL,
	Дата_предыдущего_грейда date,
	Дата_следующего_грейда date,
	FOREIGN KEY (Группа_навыков) REFERENCES dm.группы_навыков (id_группы),
	FOREIGN KEY ("User ID") REFERENCES dm.сотрудники_дар (id_сотрудника),
	FOREIGN KEY (Навыки) REFERENCES dm.навыки (id_навыка),
	FOREIGN KEY (Уровень_знаний) REFERENCES dm.уровни_знаний (id_уровня)
);
