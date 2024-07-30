CREATE SCHEMA IF NOT EXISTS  dds;
CREATE SCHEMA IF NOT EXISTS  dds_er;

--1 сотрудники_дар 
CREATE TABLE IF NOT EXISTS  dds.сотрудники_дар (
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
CREATE TABLE IF NOT EXISTS  dds.инструменты (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.инструменты (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);

--3 уровни_знаний
CREATE TABLE IF NOT EXISTS  dds.уровни_знаний (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.уровни_знаний (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);
--4 инструменты_и_уровень_знаний_сотр
CREATE TABLE IF NOT EXISTS  dds.инструменты_и_уровень_знаний_сотр (
	id INT PRIMARY KEY,
	"User ID" INT, -- что такое название
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE NULL,
	инструменты INT,
	"Уровень знаний" INT,
	FOREIGN KEY (инструменты) REFERENCES  dds.инструменты (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES  dds.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES  dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS  dds_er.инструменты_и_уровень_знаний_сотр (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	инструменты TEXT,
	"Уровень знаний" TEXT,
    "Дата создания" TIMESTAMP
);

--5 базы_данных 
CREATE TABLE IF NOT EXISTS  dds.базы_данных (
	id INT PRIMARY KEY,
	название TEXT NOT NULL, 
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.базы_данных (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);
--6 базы_данных_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS  dds.базы_данных_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT, -- что такое название
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	"Базы данных" INT,
	"Уровень знаний" INT,
	FOREIGN KEY ("Базы данных") REFERENCES  dds.базы_данных (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES  dds.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES  dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS  dds_er.базы_данных_и_уровень_знаний_сотру (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	"Базы данных" TEXT,
	"Уровень знаний" TEXT,
    "Дата создания" TIMESTAMP
);

--7 языки
CREATE TABLE IF NOT EXISTS  dds.языки (
	id INT PRIMARY KEY,
	название TEXT NOT NULL, 
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.языки (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);
--8 уровни_владения_ин
CREATE TABLE IF NOT EXISTS  dds.уровни_владения_ин (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.уровни_владения_ин (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);
--9 языки_пользователей
CREATE TABLE IF NOT EXISTS  dds.языки_пользователей (
	id INT PRIMARY KEY,
	"User ID" INT, -- что это
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	язык INT,
	"Уровень знаний ин. языка" INT,
	FOREIGN KEY (язык) REFERENCES  dds.языки (id),
	FOREIGN KEY ("Уровень знаний ин. языка") REFERENCES  dds.уровни_владения_ин  (id),
	FOREIGN KEY ("User ID") REFERENCES  dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS  dds_er.языки_пользователей (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	язык TEXT,
	"Уровень знаний ин. языка" TEXT,
    "Дата создания" TIMESTAMP
);

--10 уровень_образования
CREATE TABLE IF NOT EXISTS  dds.уровень_образования (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.уровень_образования (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);
--11 образование_пользователей
CREATE TABLE IF NOT EXISTS  dds.образование_пользователей (
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
	FOREIGN KEY ("Уровень образование") REFERENCES  dds.уровень_образования (id),
	FOREIGN KEY ("User ID") REFERENCES  dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS  dds_er.образование_пользователей (
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
	"Год окончания" TEXT,
    "Дата создания" TIMESTAMP
);

--12 сертификаты_пользователей
CREATE TABLE IF NOT EXISTS  dds.сертификаты_пользователей (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	"Год сертификата" INT,
	"Наименование сертификата" TEXT,
	"Организация, выдавшая сертификат" TEXT,
	FOREIGN KEY ("User ID") REFERENCES  dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS  dds_er.сертификаты_пользователей (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	"Год сертификата" TEXT,
	"Наименование сертификата" TEXT,
	"Организация, выдавшая сертификат" TEXT,
    "Дата создания" TIMESTAMP
);

--13 отрасли
CREATE TABLE IF NOT EXISTS  dds.отрасли (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.отрасли (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);

--14 уровни_знаний_в_отрасли
CREATE TABLE IF NOT EXISTS  dds.уровни_знаний_в_отрасли (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.уровни_знаний_в_отрасли (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);

--15 опыт_сотрудника_в_отраслях
CREATE TABLE IF NOT EXISTS  dds.опыт_сотрудника_в_отраслях (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	отрасли INT,
	"Уровень знаний в отрасли" INT,
	FOREIGN KEY (отрасли) REFERENCES  dds.отрасли (id),
	FOREIGN KEY ("Уровень знаний в отрасли") REFERENCES  dds.уровни_знаний_в_отрасли (id),
	FOREIGN KEY ("User ID") REFERENCES  dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS  dds_er.опыт_сотрудника_в_отраслях (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	отрасли TEXT,
	"Уровень знаний в отрасли" TEXT,
    "Дата создания" TIMESTAMP
);

--16 предметная_область
CREATE TABLE IF NOT EXISTS  dds.предметная_область (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.предметная_область (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);

--17 уровни_знаний_в_предметной_област
CREATE TABLE IF NOT EXISTS  dds.уровни_знаний_в_предметной_област (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.уровни_знаний_в_предметной_област (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);

--18 опыт_сотрудника_в_предметных_обла
CREATE TABLE IF NOT EXISTS  dds.опыт_сотрудника_в_предметных_обла (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	"Предментые области" INT,
	"Уровень знаний в предметной облас" INT,
	FOREIGN KEY ("Предментые области") REFERENCES  dds.предметная_область (id),
	FOREIGN KEY ("Уровень знаний в предметной облас") REFERENCES  dds.уровни_знаний_в_предметной_област (id),
	FOREIGN KEY ("User ID") REFERENCES  dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS  dds_er.опыт_сотрудника_в_предметных_обла (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	"Предментые области" TEXT,
	"Уровень знаний в предметной облас" TEXT,
    "Дата создания" TIMESTAMP
);

--19 платформы
CREATE TABLE IF NOT EXISTS  dds.платформы (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.платформы (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);

--20 платформы_и_уровень_знаний_сотруд
CREATE TABLE IF NOT EXISTS  dds.платформы_и_уровень_знаний_сотруд (
	id INT PRIMARY KEY,
	"User ID" INT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	платформы INT,
	"Уровень знаний" INT,
	FOREIGN KEY (платформы) REFERENCES  dds.платформы (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES  dds.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES  dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS  dds_er.платформы_и_уровень_знаний_сотруд (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	платформы TEXT,
	"Уровень знаний" TEXT,
    "Дата создания" TIMESTAMP
);


--21 среды_разработки
CREATE TABLE IF NOT EXISTS  dds.среды_разработки (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.среды_разработки (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);

--22 среды_разработки_и_уровень_знаний_
CREATE TABLE IF NOT EXISTS  dds.среды_разработки_и_уровень_знаний_ (
	id INT PRIMARY KEY,
	"User ID" INT, -- название
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	"Среды разработки" INT,
	"Уровень знаний" INT,
	FOREIGN KEY ("Среды разработки") REFERENCES  dds.среды_разработки (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES  dds.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES  dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS  dds_er.среды_разработки_и_уровень_знаний_ (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	"Среды разработки" TEXT,
	"Уровень знаний" TEXT,
    "Дата создания" TIMESTAMP
);

--23 типы_систем
CREATE TABLE IF NOT EXISTS  dds.типы_систем (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.типы_систем (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);

--24 типы_систем_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS  dds.типы_систем_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT, -- название
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	"Типы систем" INT,
	"Уровень знаний" INT,
	FOREIGN KEY ("Типы систем") REFERENCES  dds.типы_систем (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES  dds.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES  dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS  dds_er.типы_систем_и_уровень_знаний_сотру (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	"Типы систем" TEXT,
	"Уровень знаний" TEXT,
    "Дата создания" TIMESTAMP
);

--25 фреймворки
CREATE TABLE IF NOT EXISTS  dds.фреймворки (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.фреймворки (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);

--26 фреймворки_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS  dds.фреймворки_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT, -- название
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	фреймворки INT,
	"Уровень знаний" INT,
	FOREIGN KEY ("Уровень знаний") REFERENCES  dds.уровни_знаний (id),
	FOREIGN KEY (фреймворки) REFERENCES  dds.фреймворки (id),
	FOREIGN KEY ("User ID") REFERENCES  dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS  dds_er.фреймворки_и_уровень_знаний_сотру (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	фреймворки TEXT,
	"Уровень знаний" TEXT,
    "Дата создания" TIMESTAMP
);

--27 языки_программирования 
CREATE TABLE IF NOT EXISTS  dds.языки_программирования (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.языки_программирования (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);

--28 языки_программирования_и_уровень
CREATE TABLE IF NOT EXISTS  dds.языки_программирования_и_уровень (
	id INT PRIMARY KEY,
	"User ID" INT, -- название
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE,
	"Языки программирования" INT,
	"Уровень знаний" INT,
	FOREIGN KEY ("Уровень знаний") REFERENCES  dds.уровни_знаний (id),
	FOREIGN KEY ("Языки программирования") REFERENCES  dds.языки_программирования (id),
	FOREIGN KEY ("User ID") REFERENCES  dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS  dds_er.языки_программирования_и_уровень (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	"Языки программирования" TEXT,
	"Уровень знаний" TEXT,
    "Дата создания" TIMESTAMP
);

--29 технологии
CREATE TABLE IF NOT EXISTS  dds.технологии (
	id INT PRIMARY KEY,
	название TEXT NOT NULL,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP
);
CREATE TABLE IF NOT EXISTS  dds_er.технологии (
	id INT,
	название TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
    "Дата создания" TIMESTAMP
);

--30 технологии_и_уровень_знаний_сотру
CREATE TABLE IF NOT EXISTS  dds.технологии_и_уровень_знаний_сотру (
	id INT PRIMARY KEY,
	"User ID" INT, -- название
	активность TEXT DEFAULT 'Да',
	"Дата изм." TIMESTAMP,
	дата DATE NULL,
	технологии INT,
	"Уровень знаний" INT,
	FOREIGN KEY (технологии) REFERENCES  dds.технологии (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES  dds.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES  dds.сотрудники_дар (id)
);
CREATE TABLE IF NOT EXISTS  dds_er.технологии_и_уровень_знаний_сотру (
	id INT,
	"User ID" TEXT,
	активность TEXT DEFAULT 'Да',
	"Дата изм." TEXT,
	дата TEXT,
	технологии TEXT,
	"Уровень знаний" TEXT,
    "Дата создания" TIMESTAMP
);