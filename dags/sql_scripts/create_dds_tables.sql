CREATE SCHEMA IF NOT EXISTS dds;
CREATE SCHEMA IF NOT EXISTS dds_er;

--1 сотрудники_дар 
CREATE TABLE IF NOT EXISTS dds.сотрудники_дар (
	id INT PRIMARY KEY,
	"Дата рождения" DATE NULL,
	активность TEXT DEFAULT 'да',
	пол TEXT NULL,
	фамилия TEXT NULL,
	имя TEXT NULL,
	"Последняя авторизация" TIMESTAMP NULL,
	должность TEXT NULL,
	цфо TEXT NULL,
	"Дата регистрации" DATE NULL,
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	подразделения TEXT NULL,
	"E-Mail" TEXT NULL,
	логин TEXT NULL,
	компания TEXT NULL,
	"Город проживания" TEXT NULL
);

--2 инструменты
CREATE TABLE IF NOT EXISTS dds.инструменты (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изм." TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.инструменты_er (
	id INT,
	название TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изм." TEXT NULL
);

--3 уровни_знаний
CREATE TABLE IF NOT EXISTS dds.уровни_знаний (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изм." TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.уровни_знаний_er (
	id INT,
	название TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изм." TEXT NULL
);
--4 инструменты_и_уровень_знаний_сотр
CREATE TABLE IF NOT EXISTS dds.инструменты_и_уровень_знаний_сотр (
	id INT PRIMARY KEY,
	"User ID" INT NOT NULL, -- что такое название
	активность TEXT DEFAULT 'да',
	"Дата изм." TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	дата DATE NULL,
	инструменты INT NOT NULL,
	"Уровень знаний" INT NOT NULL,
	FOREIGN KEY (инструменты) REFERENCES dds.инструменты (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_er.инструменты_и_уровень_знаний_сотр_er (
	id INT,
	"User ID" TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изм." TEXT NULL,
	дата TEXT NULL,
	инструменты TEXT NULL,
	"Уровень знаний" TEXT NULL
);

--5 базы_данных 
CREATE TABLE IF NOT EXISTS dds.базы_данных (
	id INT PRIMARY KEY,
	название TEXT NOT NULL, 
	активность TEXT DEFAULT 'да',
	"Дата изм." TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.базы_данных_er (
	id INT,
	название TEXT NULL, 
	активность TEXT DEFAULT 'да',
	"Дата изм." TEXT NULL
);
--6 базы_данных_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS dds.базы_данных_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT NOT NULL, -- что такое название
	активность TEXT DEFAULT 'да',
	"Дата изм." TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	дата DATE NULL,
	"Базы данных" INT NOT NULL,
	"Уровень знаний" INT NOT NULL,
	FOREIGN KEY ("Базы данных") REFERENCES dds.базы_данных (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_er.базы_данных_и_уровень_знаний_сотру_er (
	id INT,
	"User ID" TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изм." TEXT NULL,
	дата TEXT NULL,
	"Базы данных" TEXT NULL,
	"Уровень знаний" TEXT NULL
);

--7 языки
CREATE TABLE IF NOT EXISTS dds.языки (
	id INT PRIMARY KEY,
	название TEXT NOT NULL, 
	активность TEXT DEFAULT 'да',
	"Дата изм." TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.языки_er (
	id INT,
	название TEXT NULL, 
	активность TEXT DEFAULT 'да',
	"Дата изм." TEXT NULL
);
--8 уровни_владения_ин
CREATE TABLE IF NOT EXISTS dds.уровни_владения_ин (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изм." TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.уровни_владения_ин_er (
	id INT,
	название TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изм." TEXT NULL
);
--9 языки_пользователей
CREATE TABLE IF NOT EXISTS dds.языки_пользователей (
	id INT PRIMARY KEY,
	"User ID" INT NOT NULL, -- что это
	активность TEXT DEFAULT 'да',
	"Дата изм." TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	язык INT NOT NULL,
	"Уровень знаний ин. языка" INT NOT NULL,
	FOREIGN KEY (язык) REFERENCES dds.языки (id),
	FOREIGN KEY ("Уровень знаний ин. языка") REFERENCES dds.уровни_владения_ин  (id),
	FOREIGN KEY ("User ID") REFERENCES dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_er.языки_пользователей_er (
	id INT,
	"User ID" TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изм." TEXT NULL,
	язык TEXT NULL,
	"Уровень знаний ин. языка" TEXT NULL
);

--10 уровень_образования
CREATE TABLE IF NOT EXISTS dds.уровень_образования (
	id INT PRIMARY KEY,
	название TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.уровень_образования_er (
	id INT,
	название TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL
);
--11 образование_пользователей
CREATE TABLE IF NOT EXISTS dds.образование_пользователей (
	id INT PRIMARY KEY,
	"User ID" INT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	"Уровень образование" INT NOT NULL,
	"Название учебного заведения" TEXT NULL,
	"Фиктивное название" TEXT NULL,
	"Факультет, кафедра" TEXT NULL,
	специальность TEXT NULL,
	квалификация TEXT NULL,
	"Год окончания" INT NULL,
	FOREIGN KEY ("Уровень образование") REFERENCES dds.уровень_образования (id),
	FOREIGN KEY ("User ID") REFERENCES dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_er.образование_пользователей_er (
	id INT,
	"User ID" TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL,
	"Уровень образование" TEXT NULL,
	"Название учебного заведения" TEXT NULL,
	"Фиктивное название" TEXT NULL,
	"Факультет, кафедра" TEXT NULL,
	специальность TEXT NULL,
	квалификация TEXT NULL,
	"Год окончания" TEXT NULL
);

--12 сертификаты_пользователей
CREATE TABLE IF NOT EXISTS dds.сертификаты_пользователей (
	id INT PRIMARY KEY,
	"User ID" INT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	"Год сертификата" INT NULL,
	"Наименование сертификата" TEXT NOT NULL,
	"Организация, выдавшая сертификат" TEXT NULL,
	FOREIGN KEY ("User ID") REFERENCES dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_er.сертификаты_пользователей_er (
	id INT,
	"User ID" TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL,
	"Год сертификата" TEXT NULL,
	"Наименование сертификата" TEXT NULL,
	"Организация, выдавшая сертификат" TEXT NULL
);

--13 отрасли
CREATE TABLE IF NOT EXISTS dds.отрасли (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.отрасли_er (
	id INT,
	название TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL
);

--14 уровни_знаний_в_отрасли
CREATE TABLE IF NOT EXISTS dds.уровни_знаний_в_отрасли (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.уровни_знаний_в_отрасли_er (
	id INT,
	название TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL
);

--15 опыт_сотрудника_в_отраслях
CREATE TABLE IF NOT EXISTS dds.опыт_сотрудника_в_отраслях (
	id INT PRIMARY KEY,
	"User ID" INT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	дата DATE NULL,
	отрасли INT NOT NULL,
	"Уровень знаний в отрасли" INT NOT NULL,
	FOREIGN KEY (отрасли) REFERENCES dds.отрасли (id),
	FOREIGN KEY ("Уровень знаний в отрасли") REFERENCES dds.уровни_знаний_в_отрасли (id),
	FOREIGN KEY ("User ID") REFERENCES dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_er.опыт_сотрудника_в_отраслях_er (
	id INT,
	"User ID" TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL,
	дата TEXT NULL,
	отрасли TEXT NULL,
	"Уровень знаний в отрасли" TEXT NULL
);

--16 предметная_область
CREATE TABLE IF NOT EXISTS dds.предметная_область (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.предметная_область_er (
	id INT,
	название TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL
);

--17 уровни_знаний_в_предметной_област
CREATE TABLE IF NOT EXISTS dds.уровни_знаний_в_предметной_област (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.уровни_знаний_в_предметной_област_er (
	id INT,
	название TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL
);

--18 опыт_сотрудника_в_предметных_обла
CREATE TABLE IF NOT EXISTS dds.опыт_сотрудника_в_предметных_обла (
	id INT PRIMARY KEY,
	"User ID" INT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	дата DATE NULL,
	"Предментые области" INT NOT NULL,
	"Уровень знаний в предметной облас" INT NOT NULL,
	FOREIGN KEY ("Предментые области") REFERENCES dds.предметная_область (id),
	FOREIGN KEY ("Уровень знаний в предметной облас") REFERENCES dds.уровни_знаний_в_предметной_област (id),
	FOREIGN KEY ("User ID") REFERENCES dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_er.опыт_сотрудника_в_предметных_обла_er (
	id INT,
	"User ID" TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL,
	дата TEXT NULL,
	"Предментые области" TEXT NULL,
	"Уровень знаний в предметной облас" TEXT NULL
);

--19 платформы
CREATE TABLE IF NOT EXISTS dds.платформы (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.платформы_er (
	id INT,
	название TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL
);

--20 платформы_и_уровень_знаний_сотруд
CREATE TABLE IF NOT EXISTS dds.платформы_и_уровень_знаний_сотруд (
	id INT PRIMARY KEY,
	"User ID" INT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	дата DATE NULL,
	платформы INT NOT NULL,
	"Уровень знаний" INT NOT NULL,
	FOREIGN KEY (платформы) REFERENCES dds.платформы (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_er.платформы_и_уровень_знаний_сотруд_er (
	id INT,
	"User ID" TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL,
	дата TEXT NULL,
	платформы TEXT NULL,
	"Уровень знаний" TEXT NULL
);


--21 среды_разработки
CREATE TABLE IF NOT EXISTS dds.среды_разработки (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.среды_разработки_er (
	id INT,
	название TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL
);

--22 среды_разработки_и_уровень_знаний_
CREATE TABLE IF NOT EXISTS dds.среды_разработки_и_уровень_знаний_ (
	id INT PRIMARY KEY,
	"User ID" INT NULL, -- название
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	дата DATE NULL,
	"Среды разработки" INT NOT NULL,
	"Уровень знаний" INT NOT NULL,
	FOREIGN KEY ("Среды разработки") REFERENCES dds.среды_разработки (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_er.среды_разработки_и_уровень_знаний__er (
	id INT,
	"User ID" TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL,
	дата TEXT NULL,
	"Среды разработки" TEXT NULL,
	"Уровень знаний" TEXT NULL
);

--23 типы_систем
CREATE TABLE IF NOT EXISTS dds.типы_систем (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.типы_систем_er (
	id INT,
	название TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL
);

--24 типы_систем_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS dds.типы_систем_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT NULL, -- название
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	дата DATE NULL,
	"Типы систем" INT NOT NULL,
	"Уровень знаний" INT NOT NULL,
	FOREIGN KEY ("Типы систем") REFERENCES dds.типы_систем (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_er.типы_систем_и_уровень_знаний_сотру_er (
	id INT,
	"User ID" TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL,
	дата TEXT NULL,
	"Типы систем" TEXT NULL,
	"Уровень знаний" TEXT NULL
);

--25 фреймворки
CREATE TABLE IF NOT EXISTS dds.фреймворки (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.фреймворки_er (
	id INT,
	название TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL
);

--26 фреймворки_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS dds.фреймворки_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT NULL, -- название
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	дата DATE NULL,
	фреймворки INT NOT NULL,
	"Уровень знаний" INT NOT NULL,
	FOREIGN KEY ("Уровень знаний") REFERENCES dds.уровни_знаний (id),
	FOREIGN KEY (фреймворки) REFERENCES dds.фреймворки (id),
	FOREIGN KEY ("User ID") REFERENCES dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_er.фреймворки_и_уровень_знаний_сотру_er (
	id INT,
	"User ID" TEXT NULL, 
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL,
	дата TEXT NULL,
	фреймворки TEXT NULL,
	"Уровень знаний" TEXT NULL
);

--27 языки_программирования 
CREATE TABLE IF NOT EXISTS dds.языки_программирования (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.языки_программирования_er (
	id INT,
	название TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL
);

--28 языки_программирования_и_уровень
CREATE TABLE IF NOT EXISTS dds.языки_программирования_и_уровень (
	id INT PRIMARY KEY,
	"User ID" INT NULL, -- название
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	дата DATE NULL,
	"Языки программирования" INT NOT NULL,
	"Уровень знаний" INT NOT NULL,
	FOREIGN KEY ("Уровень знаний") REFERENCES dds.уровни_знаний (id),
	FOREIGN KEY ("Языки программирования") REFERENCES dds.языки_программирования (id),
	FOREIGN KEY ("User ID") REFERENCES dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_er.языки_программирования_и_уровень_er (
	id INT,
	"User ID" TEXT NULL, 
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL,
	дата TEXT NULL,
	"Языки программирования" TEXT NULL,
	"Уровень знаний" TEXT NULL
);

--29 технологии
CREATE TABLE IF NOT EXISTS dds.технологии (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS dds_er.технологии_er (
	id INT,
	название TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL
);

--30 технологии_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS dds.технологии_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT NULL, -- название
	активность TEXT DEFAULT 'да',
	"Дата изменения" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	дата DATE NULL,
	технологии INT NOT NULL,
	"Уровень знаний" INT NOT NULL,
	FOREIGN KEY (технологии) REFERENCES dds.технологии (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS dds_er.технологии_и_уровень_знаний_сотру_er (
	id INT,
	"User ID" TEXT NULL,
	активность TEXT DEFAULT 'да',
	"Дата изменения" TEXT NULL,
	дата TEXT NULL,
	технологии TEXT NULL,
	"Уровень знаний" TEXT NULL
);