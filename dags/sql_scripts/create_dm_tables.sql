DROP SCHEMA IF EXISTS dm_egor CASCADE;
CREATE SCHEMA IF NOT EXISTS dm_egor;

-- 1 сотрудники_дар
CREATE TABLE IF NOT EXISTS dm_egor.сотрудники_дар (
	ID_сотрудника INT PRIMARY KEY,
	Фамилия TEXT,
	Имя TEXT,
	Роль TEXT NOT NULL
);

-- 2 группы_навыков
CREATE TABLE IF NOT EXISTS dm_egor.группы_навыков (
	ID_группы SERIAL PRIMARY KEY,
	Группа_навыков TEXT NOT NULL
);

-- 3 навыки
CREATE TABLE IF NOT EXISTS dm_egor.навыки (
	ID_навыка INT PRIMARY KEY,
	Название TEXT NOT NULL
);

-- 4 уровни_знаний
CREATE TABLE IF NOT EXISTS dm_egor.уровни_знаний (
	ID_уровня INT PRIMARY KEY,
	Название TEXT NOT NULL
);

-- 5 группы_навыков_и_уровень_знаний_сотруд
CREATE TABLE IF NOT EXISTS dm_egor.группы_навыков_и_уровень_знаний_сотруд (
	ID INT PRIMARY KEY,
    "Дата_изм." TIMESTAMP,
    Дата DATE,
	"User ID" INT,
	"Группа_навыков" INT,
    "Навыки" INT,
	"Уровень_знаний" INT,
    FOREIGN KEY ("Группа_навыков") REFERENCES dm_egor.группы_навыков (ID_группы),
    FOREIGN KEY ("Уровень_знаний") REFERENCES dm_egor.уровни_знаний (ID_уровня),
	FOREIGN KEY ("Навыки") REFERENCES dm_egor.навыки (ID_навыка),
	FOREIGN KEY ("User ID") REFERENCES dm_egor.сотрудники_дар (ID_сотрудника)
);
