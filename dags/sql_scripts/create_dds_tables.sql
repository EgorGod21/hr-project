CREATE SCHEMA IF NOT EXISTS dds_egor;
CREATE SCHEMA IF NOT EXISTS dds_egor_er;

--1 сотрудники_дар 
CREATE TABLE IF NOT EXISTS dds_egor.сотрудники_дар (
	id INT PRIMARY KEY,
	"Дата рождения" DATE,
	активность TEXT DEFAULT 'Да',
	пол TEXT,
	фамилия TEXT,
	имя TEXT,
	"Последняя авторизация" TIMESTAMP,
	должность TEXT,
	цфо TEXT,
	"Дата регистрации" DATE,
	"Дата изм." TIMESTAMP,
	подразделения TEXT,
	"E-Mail" TEXT,
	логин TEXT,
	компания TEXT,
	"Город проживания" TEXT
);

--2 инструменты
CREATE TABLE IF NOT EXISTS dds_egor.инструменты (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.инструменты (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);

--3 уровни_знаний
CREATE TABLE IF NOT EXISTS dds_egor.уровни_знаний (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.уровни_знаний (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);
--4 инструменты_и_уровень_знаний_сотр
CREATE TABLE IF NOT EXISTS dds_egor.инструменты_и_уровень_знаний_сотр (
	id INT PRIMARY KEY,
	"User ID" INT, -- что такое название
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE NULL,
	инструменты INT,
	"Уровень знаний" INT,
	FOREIGN KEY (инструменты) REFERENCES dds_egor.инструменты (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_egor.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_egor.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_egor_er.инструменты_и_уровень_знаний_сотр (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	инструменты TEXT,
	"Уровень знаний" TEXT
);

--5 базы_данных 
CREATE TABLE IF NOT EXISTS dds_egor.базы_данных (
	id INT PRIMARY KEY,
	название TEXT NOT NULL, 
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.базы_данных (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);
--6 базы_данных_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS dds_egor.базы_данных_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT, -- что такое название
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	"Базы данных" INT,
	"Уровень знаний" INT,
	FOREIGN KEY ("Базы данных") REFERENCES dds_egor.базы_данных (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_egor.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_egor.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_egor_er.базы_данных_и_уровень_знаний_сотру (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	"Базы данных" TEXT,
	"Уровень знаний" TEXT
);

--7 языки
CREATE TABLE IF NOT EXISTS dds_egor.языки (
	id INT PRIMARY KEY,
	название TEXT NOT NULL, 
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.языки (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);
--8 уровни_владения_ин
CREATE TABLE IF NOT EXISTS dds_egor.уровни_владения_ин (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.уровни_владения_ин (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);
--9 языки_пользователей
CREATE TABLE IF NOT EXISTS dds_egor.языки_пользователей (
	id INT PRIMARY KEY,
	"User ID" INT, -- что это
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	язык INT,
	"Уровень знаний ин. языка" INT,
	FOREIGN KEY (язык) REFERENCES dds_egor.языки (id),
	FOREIGN KEY ("Уровень знаний ин. языка") REFERENCES dds_egor.уровни_владения_ин  (id),
	FOREIGN KEY ("User ID") REFERENCES dds_egor.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_egor_er.языки_пользователей (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	язык TEXT,
	"Уровень знаний ин. языка" TEXT
);

--10 уровень_образования
CREATE TABLE IF NOT EXISTS dds_egor.уровень_образования (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.уровень_образования (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);
--11 образование_пользователей
CREATE TABLE IF NOT EXISTS dds_egor.образование_пользователей (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	"Уровень образование" INT,
	"Название учебного заведения" TEXT,
	"Фиктивное название" TEXT,
	"Факультет, кафедра" TEXT,
	специальность TEXT,
	квалификация TEXT,
	"Год окончания" INT,
	FOREIGN KEY ("Уровень образование") REFERENCES dds_egor.уровень_образования (id),
	FOREIGN KEY ("User ID") REFERENCES dds_egor.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_egor_er.образование_пользователей (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	"Уровень образование" TEXT,
	"Название учебного заведения" TEXT,
	"Фиктивное название" TEXT,
	"Факультет, кафедра" TEXT,
	специальность TEXT,
	квалификация TEXT,
	"Год окончания" TEXT
);

--12 сертификаты_пользователей
CREATE TABLE IF NOT EXISTS dds_egor.сертификаты_пользователей (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	"Год сертификата" INT,
	"Наименование сертификата" TEXT,
	"Организация, выдавшая сертификат" TEXT,
	FOREIGN KEY ("User ID") REFERENCES dds_egor.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_egor_er.сертификаты_пользователей (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	"Год сертификата" TEXT,
	"Наименование сертификата" TEXT,
	"Организация, выдавшая сертификат" TEXT
);

--13 отрасли
CREATE TABLE IF NOT EXISTS dds_egor.отрасли (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.отрасли (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);

--14 уровни_знаний_в_отрасли
CREATE TABLE IF NOT EXISTS dds_egor.уровни_знаний_в_отрасли (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.уровни_знаний_в_отрасли (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);

--15 опыт_сотрудника_в_отраслях
CREATE TABLE IF NOT EXISTS dds_egor.опыт_сотрудника_в_отраслях (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	отрасли INT,
	"Уровень знаний в отрасли" INT,
	FOREIGN KEY (отрасли) REFERENCES dds_egor.отрасли (id),
	FOREIGN KEY ("Уровень знаний в отрасли") REFERENCES dds_egor.уровни_знаний_в_отрасли (id),
	FOREIGN KEY ("User ID") REFERENCES dds_egor.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_egor_er.опыт_сотрудника_в_отраслях (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	отрасли TEXT,
	"Уровень знаний в отрасли" TEXT
);

--16 предметная_область
CREATE TABLE IF NOT EXISTS dds_egor.предметная_область (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.предметная_область (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);

--17 уровни_знаний_в_предметной_област
CREATE TABLE IF NOT EXISTS dds_egor.уровни_знаний_в_предметной_област (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.уровни_знаний_в_предметной_област (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);

--18 опыт_сотрудника_в_предметных_обла
CREATE TABLE IF NOT EXISTS dds_egor.опыт_сотрудника_в_предметных_обла (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	"Предментые области" INT,
	"Уровень знаний в предметной облас" INT,
	FOREIGN KEY ("Предментые области") REFERENCES dds_egor.предметная_область (id),
	FOREIGN KEY ("Уровень знаний в предметной облас") REFERENCES dds_egor.уровни_знаний_в_предметной_област (id),
	FOREIGN KEY ("User ID") REFERENCES dds_egor.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_egor_er.опыт_сотрудника_в_предметных_обла (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	"Предментые области" TEXT,
	"Уровень знаний в предметной облас" TEXT
);

--19 платформы
CREATE TABLE IF NOT EXISTS dds_egor.платформы (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.платформы (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);

--20 платформы_и_уровень_знаний_сотруд
CREATE TABLE IF NOT EXISTS dds_egor.платформы_и_уровень_знаний_сотруд (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	платформы INT,
	"Уровень знаний" INT,
	FOREIGN KEY (платформы) REFERENCES dds_egor.платформы (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_egor.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_egor.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_egor_er.платформы_и_уровень_знаний_сотруд (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	платформы TEXT,
	"Уровень знаний" TEXT
);


--21 среды_разработки
CREATE TABLE IF NOT EXISTS dds_egor.среды_разработки (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.среды_разработки (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);

--22 среды_разработки_и_уровень_знаний_
CREATE TABLE IF NOT EXISTS dds_egor.среды_разработки_и_уровень_знаний_ (
	id INT PRIMARY KEY,
	"User ID" INT, -- название
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	"Среды разработки" INT,
	"Уровень знаний" INT,
	FOREIGN KEY ("Среды разработки") REFERENCES dds_egor.среды_разработки (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_egor.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_egor.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_egor_er.среды_разработки_и_уровень_знаний_ (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	"Среды разработки" TEXT,
	"Уровень знаний" TEXT
);

--23 типы_систем
CREATE TABLE IF NOT EXISTS dds_egor.типы_систем (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.типы_систем (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);

--24 типы_систем_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS dds_egor.типы_систем_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT, -- название
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	"Типы систем" INT,
	"Уровень знаний" INT,
	FOREIGN KEY ("Типы систем") REFERENCES dds_egor.типы_систем (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_egor.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_egor.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_egor_er.типы_систем_и_уровень_знаний_сотру (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	"Типы систем" TEXT,
	"Уровень знаний" TEXT
);

--25 фреймворки
CREATE TABLE IF NOT EXISTS dds_egor.фреймворки (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.фреймворки (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);

--26 фреймворки_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS dds_egor.фреймворки_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT, -- название
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	фреймворки INT,
	"Уровень знаний" INT,
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_egor.уровни_знаний (id),
	FOREIGN KEY (фреймворки) REFERENCES dds_egor.фреймворки (id),
	FOREIGN KEY ("User ID") REFERENCES dds_egor.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_egor_er.фреймворки_и_уровень_знаний_сотру (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	фреймворки TEXT,
	"Уровень знаний" TEXT
);

--27 языки_программирования 
CREATE TABLE IF NOT EXISTS dds_egor.языки_программирования (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.языки_программирования (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);

--28 языки_программирования_и_уровень
CREATE TABLE IF NOT EXISTS dds_egor.языки_программирования_и_уровень (
	id INT PRIMARY KEY,
	"User ID" INT, -- название
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	"Языки программирования" INT,
	"Уровень знаний" INT,
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_egor.уровни_знаний (id),
	FOREIGN KEY ("Языки программирования") REFERENCES dds_egor.языки_программирования (id),
	FOREIGN KEY ("User ID") REFERENCES dds_egor.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_egor_er.языки_программирования_и_уровень (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	"Языки программирования" TEXT,
	"Уровень знаний" TEXT
);

--29 технологии
CREATE TABLE IF NOT EXISTS dds_egor.технологии (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_egor_er.технологии (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT
);

--30 технологии_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS dds_egor.технологии_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT, -- название
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE NULL,
	технологии INT,
	"Уровень знаний" INT,
	FOREIGN KEY (технологии) REFERENCES dds_egor.технологии (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_egor.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_egor.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_egor_er.технологии_и_уровень_знаний_сотру (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	технологии TEXT,
	"Уровень знаний" TEXT
);