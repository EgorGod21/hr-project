-- Создание схемы "dds_ira"
CREATE SCHEMA IF NOT EXISTS dds_ira;

--Создание таблицы "базы_данных"
CREATE TABLE IF NOT EXISTS dds_ira.базы_данных (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "инструменты"
CREATE TABLE IF NOT EXISTS dds_ira.инструменты (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "отрасли"
CREATE TABLE IF NOT EXISTS dds_ira.отрасли (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "платформы"
CREATE TABLE IF NOT EXISTS dds_ira.платформы (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "предметная_область"
CREATE TABLE IF NOT EXISTS dds_ira.предметная_область (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "сотрудники_дар"
CREATE TABLE IF NOT EXISTS dds_ira.сотрудники_дар (
	id integer PRIMARY KEY,
	"Дата рождения" date,
	активность text,
	пол text,
	фамилия text,
	имя text,
	"Последняя авторизация" date,
	должность text,
	цфо text,
	"Дата регистрации" date,
	"Дата изменения" TIMESTAMP,
	подразделения text,
	"E-Mail" text,
	логин text,
	компания text,
	"Город проживания" text
);

--Создание таблицы "среды_разработки"
CREATE TABLE IF NOT EXISTS dds_ira.среды_разработки (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "технологии"
CREATE TABLE IF NOT EXISTS dds_ira.технологии (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "типы_систем"
CREATE TABLE IF NOT EXISTS dds_ira.типы_систем (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "уровень_образования"
CREATE TABLE IF NOT EXISTS dds_ira.уровень_образования (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "уровни_владения_ин"
CREATE TABLE IF NOT EXISTS dds_ira.уровни_владения_ин (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "уровни_знаний"
CREATE TABLE IF NOT EXISTS dds_ira.уровни_знаний (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "уровни_знаний_в_отрасли"
CREATE TABLE IF NOT EXISTS dds_ira.уровни_знаний_в_отрасли (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "уровни_знаний_в_предметной_област"
CREATE TABLE IF NOT EXISTS dds_ira.уровни_знаний_в_предметной_област (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "фреймворки"
CREATE TABLE IF NOT EXISTS dds_ira.фреймворки (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "языки"
CREATE TABLE IF NOT EXISTS dds_ira.языки (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "языки_программирования"
CREATE TABLE IF NOT EXISTS dds_ira.языки_программирования (
	id integer PRIMARY KEY,
	название text NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP
);

--Создание таблицы "сертификаты_пользователей"
CREATE TABLE IF NOT EXISTS dds_ira.сертификаты_пользователей (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP,
	"Год сертификата" integer,
	"Наименование сертификата" text,
	"Организация, выдавшая сертификат" text,
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "базы_данных_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS dds_ira.базы_данных_и_уровень_знаний_сотру (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP,
	"Базы данных" integer NOT NULL,
	дата date,
	"Уровень знаний" integer NOT NULL,
	FOREIGN KEY ("Базы данных") REFERENCES dds_ira.базы_данных (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "инструменты_и_уровень_знаний_сотр"
CREATE TABLE IF NOT EXISTS dds_ira.инструменты_и_уровень_знаний_сотр (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP,
	дата date,
	инструменты integer NOT NULL,
	"Уровень знаний" integer NOT NULL,
	FOREIGN KEY (инструменты) REFERENCES dds_ira.инструменты (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "образование_пользователей"
CREATE TABLE IF NOT EXISTS dds_ira.образование_пользователей (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP,
	"Уровень образование" integer NOT NULL,
	"Название учебного заведения" text,
	"Фиктивное название" text,
	"Факультет, кафедра" text,
	специальность text,
	квалификация text,
	"Год окончания" integer,
	FOREIGN KEY ("Уровень образование") REFERENCES dds_ira.уровень_образования (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "опыт_сотрудника_в_отраслях"
CREATE TABLE IF NOT EXISTS dds_ira.опыт_сотрудника_в_отраслях (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP,
	дата date,
	отрасли integer NOT NULL,
	"Уровень знаний в отрасли" int NOT NULL,
	FOREIGN KEY (отрасли) REFERENCES dds_ira.отрасли (id),
	FOREIGN KEY ("Уровень знаний в отрасли") REFERENCES dds_ira.уровни_знаний_в_отрасли (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "опыт_сотрудника_в_предметных_обла"
CREATE TABLE IF NOT EXISTS dds_ira.опыт_сотрудника_в_предметных_обла (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP,
	дата date,
	"Предментые области" integer NOT NULL,
	"Уровень знаний в предметной облас" integer NOT NULL,
	FOREIGN KEY ("Предментые области") REFERENCES dds_ira.предметная_область (id),
	FOREIGN KEY ("Уровень знаний в предметной облас") REFERENCES dds_ira.уровни_знаний_в_предметной_област (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "платформы_и_уровень_знаний_сотруд"
CREATE TABLE IF NOT EXISTS dds_ira.платформы_и_уровень_знаний_сотруд (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP,
	дата date,
	платформы integer NOT NULL,
	"Уровень знаний" integer NOT NULL,
	FOREIGN KEY (платформы) REFERENCES dds_ira.платформы (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "среды_разработки_и_уровень_знаний_"
CREATE TABLE IF NOT EXISTS dds_ira.среды_разработки_и_уровень_знаний_ (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP,
	дата date,
	"Среды разработки" integer NOT NULL,
	"Уровень знаний" integer NOT NULL,
	FOREIGN KEY ("Среды разработки") REFERENCES dds_ira.среды_разработки (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "технологии_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS dds_ira.технологии_и_уровень_знаний_сотру (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP,
	дата date,
	технологии integer NOT NULL,
	"Уровень знаний" integer NOT NULL,
	FOREIGN KEY (технологии) REFERENCES dds_ira.технологии (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "типы_систем_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS dds_ira.типы_систем_и_уровень_знаний_сотру (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP,
	дата date,
	"Типы систем" integer NOT NULL,
	"Уровень знаний" integer NOT NULL,
	FOREIGN KEY ("Типы систем") REFERENCES dds_ira.типы_систем (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "фреймворки_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS dds_ira.фреймворки_и_уровень_знаний_сотру (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP,
	дата date,
	"Уровень знаний" integer NOT NULL,
	фреймворки integer NOT NULL,
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY (фреймворки) REFERENCES dds_ira.фреймворки (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "языки_пользователей"
CREATE TABLE IF NOT EXISTS dds_ira.языки_пользователей (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP,
	язык integer NOT NULL,
	"Уровень знаний ин. языка" integer NULL,
	FOREIGN KEY (язык) REFERENCES dds_ira.языки (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "языки_программирования_и_уровень"
CREATE TABLE IF NOT EXISTS dds_ira.языки_программирования_и_уровень (
	id integer PRIMARY KEY,
	"User ID" integer NOT NULL,
	активность text,
	"Дата изм." TIMESTAMP,
	дата date,
	"Уровень знаний" integer NOT NULL,
	"Языки программирования" integer NOT NULL,
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY ("Языки программирования") REFERENCES dds_ira.языки_программирования (id),
	FOREIGN KEY ("User ID") REFERENCES dds_ira.сотрудники_дар (id)
);
