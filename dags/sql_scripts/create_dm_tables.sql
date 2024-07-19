DROP SCHEMA IF EXISTS dm CASCADE;
CREATE SCHEMA IF NOT EXISTS dm;

-- 1 сотрудники_дар
CREATE TABLE IF NOT EXISTS dm.сотрудники_дар (
	ID_сотрудника INT PRIMARY KEY,
	Фамилия TEXT,
	Имя TEXT,
	Роль TEXT NOT NULL
);

-- 2 группы_навыков
CREATE TABLE IF NOT EXISTS dm.группы_навыков (
	ID_группы SERIAL PRIMARY KEY,
	Группа_навыков TEXT NOT NULL
);

-- 3 навыки
CREATE TABLE IF NOT EXISTS dm.навыки (
	ID_навыка INT PRIMARY KEY,
	Название TEXT NOT NULL
);

-- 4 уровни_знаний
CREATE TABLE IF NOT EXISTS dm.уровни_знаний (
	ID_уровня INT PRIMARY KEY,
	Название TEXT NOT NULL
);

-- 5 группы_навыков_и_уровень_знаний_сотруд
CREATE TABLE IF NOT EXISTS dm.группы_навыков_и_уровень_знаний_сотруд (
	ID INT PRIMARY KEY,
    Дата DATE,
	"User ID" INT,
	"Группа_навыков" INT,
    "Навыки" INT,
	"Уровень_знаний" INT,
    Индикатор BIGINT,
    FOREIGN KEY ("Группа_навыков") REFERENCES dm.группы_навыков (ID_группы),
    FOREIGN KEY ("Уровень_знаний") REFERENCES dm.уровни_знаний (ID_уровня),
	FOREIGN KEY ("Навыки") REFERENCES dm.навыки (ID_навыка),
	FOREIGN KEY ("User ID") REFERENCES dm.сотрудники_дар (ID_сотрудника)
);
