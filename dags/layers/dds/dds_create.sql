-- Создание схемы "dds_ira"
CREATE SCHEMA IF NOT EXISTS dds_ira;

--Создание таблицы "базы_данных" 
CREATE TABLE IF NOT EXISTS dds_ira.базы_данных (
	id text PRIMARY KEY,
	название character varying(50) NULL,
	активность varchar(50) NULL,
	"Сорт." integer NULL,
	"Дата изм." character varying(50) NULL
);

--Создание таблицы "инструменты"
CREATE TABLE IF NOT EXISTS dds_ira.инструменты (
	id text PRIMARY KEY,
	название character varying(50) NULL,
	активность character varying(50) NULL,
	"Сорт." integer NULL,
	"Дата изм." character varying(50) NULL
);

--Создание таблицы "отрасли"
CREATE TABLE IF NOT EXISTS dds_ira.отрасли (
	id text PRIMARY KEY,
	название character varying(50) NULL,
	активность character varying(50) NULL,
	"Сорт." integer NULL,
	"Дата изм." character varying(50) NULL
);

--Создание таблицы "платформы"
CREATE TABLE IF NOT EXISTS dds_ira.платформы (
	id text PRIMARY KEY,
	название character varying(50) NULL,
	активность character varying(50) NULL,
	"Сорт." integer NULL,
	"Дата изм." character varying(50) NULL
);

--Создание таблицы "предметная_область"
CREATE TABLE IF NOT EXISTS dds_ira.предметная_область (
	id text PRIMARY KEY,
	название character varying(50) NULL,
	активность character varying(50) NULL,
	"Сорт." integer NULL,
	"Дата изм." character varying(50) NULL
);

--Создание таблицы "сертификаты_пользователей"
CREATE TABLE IF NOT EXISTS dds_ira.сертификаты_пользователей (
	id text PRIMARY KEY,
	"User ID" integer NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL,
	"Год сертификата" integer NULL,
	"Наименование сертификата" text NULL,
	"Организация, выдавшая сертификат" text NULL
);

--Создание таблицы "сотрудники_дар"
CREATE TABLE IF NOT EXISTS dds_ira.сотрудники_дар (
	id text PRIMARY KEY,
	"Дата рождения" text NULL,
	активность text NULL,
	пол text NULL,
	фамилия text NULL,
	имя text NULL,
	"Последняя авторизация" text NULL,
	должность text NULL,
	цфо text NULL,
	"Дата регистрации" text NULL,
	"Дата изменения" text NULL,
	подразделения text NULL,
	"E-Mail" text NULL,
	логин text NULL,
	компания text NULL,
	"Город проживания" text NULL
);

--Создание таблицы "среды_разработки"
CREATE TABLE IF NOT EXISTS dds_ira.среды_разработки (
	id text PRIMARY KEY,
	название text NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL
);

--Создание таблицы "технологии"
CREATE TABLE IF NOT EXISTS dds_ira.технологии (
	id text PRIMARY KEY,
	название text NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL
);

--Создание таблицы "типы_систем"
CREATE TABLE IF NOT EXISTS dds_ira.типы_систем (
	id text PRIMARY KEY,
	название text NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL
);

--Создание таблицы "уровень_образования"
CREATE TABLE IF NOT EXISTS dds_ira.уровень_образования (
	id text PRIMARY KEY,
	название text NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL
);

--Создание таблицы "уровни_владения_ин"
CREATE TABLE IF NOT EXISTS dds_ira.уровни_владения_ин (
	id text PRIMARY KEY,
	название text NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL
);

--Создание таблицы "уровни_знаний"
CREATE TABLE IF NOT EXISTS dds_ira.уровни_знаний (
	id text PRIMARY KEY,
	название text NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL
);

--Создание таблицы "уровни_знаний_в_отрасли"
CREATE TABLE IF NOT EXISTS dds_ira.уровни_знаний_в_отрасли (
	id text PRIMARY KEY,
	название text NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL
);

--Создание таблицы "уровни_знаний_в_предметной_област"
CREATE TABLE IF NOT EXISTS dds_ira.уровни_знаний_в_предметной_област (
	id text PRIMARY KEY,
	название text NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL
);

--Создание таблицы "фреймворки"
CREATE TABLE IF NOT EXISTS dds_ira.фреймворки (
	id text PRIMARY KEY,
	название text NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL
);

--Создание таблицы "языки"
CREATE TABLE IF NOT EXISTS dds_ira.языки (
	id text PRIMARY KEY,
	название text NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL
);

--Создание таблицы "языки_программирования"
CREATE TABLE IF NOT EXISTS dds_ira.языки_программирования (
	id text PRIMARY KEY,
	название text NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL
);

--Создание таблицы "базы_данных_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS dds_ira.базы_данных_и_уровень_знаний_сотру (
	id integer PRIMARY KEY,
	название character varying(50) NULL,
	активность character varying(50) NULL,
	"Сорт." integer NULL,
	"Дата изм." character varying(50) NULL,
	"Базы данных" character varying(50) NOT NULL,
	дата character varying(50) NULL,
	"Уровень знаний" character varying(50) NOT NULL,
	FOREIGN KEY ("Базы данных") REFERENCES dds_ira.базы_данных (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id)
);

--Создание таблицы "инструменты_и_уровень_знаний_сотр"
CREATE TABLE IF NOT EXISTS dds_ira.инструменты_и_уровень_знаний_сотр (
	id integer PRIMARY KEY,
	название character varying(50) NULL,
	активность character varying(50) NULL,
	"Сорт." integer NULL,
	"Дата изм." character varying(50) NULL,
	дата character varying(50) NULL,
	инструменты character varying(64) NOT NULL,
	"Уровень знаний" character varying(50) NOT NULL,
	FOREIGN KEY (инструменты) REFERENCES dds_ira.инструменты (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id)
);

--Создание таблицы "образование_пользователей"
CREATE TABLE IF NOT EXISTS dds_ira.образование_пользователей (
	id integer PRIMARY KEY,
	"User ID" integer NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL,
	"Уровень образование" text NOT NULL,
	"Название учебного заведения" text NULL,
	"Фиктивное название" text NULL,
	"Факультет, кафедра" text NULL,
	специальность text NULL,
	квалификация text NULL,
	"Год окончания" integer NULL,
	FOREIGN KEY ("Уровень образование") REFERENCES dds_ira.уровень_образования (id)
);

--Создание таблицы "опыт_сотрудника_в_отраслях"
CREATE TABLE IF NOT EXISTS dds_ira.опыт_сотрудника_в_отраслях (
	id integer PRIMARY KEY,
	"User ID" integer NULL,
	активность character varying(50) NULL,
	"Сорт." integer NULL,
	"Дата изм." character varying(50) NULL,
	дата character varying(50) NULL,
	отрасли character varying(50) NOT NULL,
	"Уровень знаний в отрасли" character varying(128) NOT NULL,
	FOREIGN KEY (отрасли) REFERENCES dds_ira.отрасли (id),
	FOREIGN KEY ("Уровень знаний в отрасли") REFERENCES dds_ira.уровни_знаний_в_отрасли (id)
);

--Создание таблицы "опыт_сотрудника_в_предметных_обла"
CREATE TABLE IF NOT EXISTS dds_ira.опыт_сотрудника_в_предметных_обла (
	id integer PRIMARY KEY,
	"User ID" integer NULL,
	активность character varying(50) NULL,
	"Сорт." integer NULL,
	"Дата изм." character varying NULL,
	дата character varying(50) NULL,
	"Предментые области" character varying(50) NOT NULL,
	"Уровень знаний в предметной облас" character varying(128) NOT NULL,
	FOREIGN KEY ("Предментые области") REFERENCES dds_ira.предметная_область (id),
	FOREIGN KEY ("Уровень знаний в предметной облас") REFERENCES dds_ira.уровни_знаний_в_предметной_област (id)
);

--Создание таблицы "платформы_и_уровень_знаний_сотруд"
CREATE TABLE IF NOT EXISTS dds_ira.платформы_и_уровень_знаний_сотруд (
	id integer PRIMARY KEY,
	"User ID" integer NULL,
	активность character varying(50) NULL,
	"Сорт." integer NULL,
	"Дата изм." character varying(50) NULL,
	дата character varying(50) NULL,
	платформы character varying(64) NOT NULL,
	"Уровень знаний" character varying(50) NOT NULL,
	FOREIGN KEY (платформы) REFERENCES dds_ira.платформы (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id)
);

--Создание таблицы "резюмедар"
CREATE TABLE IF NOT EXISTS dds_ira.резюмедар (
	"ResumeID" integer PRIMARY KEY,
	"UserID" text NOT NULL,
	"Активность" text NULL,
	"Образование" text NULL,
	"Сертификаты/Курсы" text NULL,
	"Языки" text NULL,
	"Базыданных" text NULL,
	"Инструменты" text NULL,
	"Отрасли" text NULL,
	"Платформы" text NULL,
	"Предметныеобласти" text NULL,
	"Средыразработки" text NULL,
	"Типысистем" text NULL,
	"Фреймворки" text NULL,
	"Языкипрограммирования" text NULL,
	"Технологии" text NULL,
	FOREIGN KEY ("UserID") REFERENCES dds_ira.сотрудники_дар (id)
);

--Создание таблицы "среды_разработки_и_уровень_знаний_"
CREATE TABLE IF NOT EXISTS dds_ira.среды_разработки_и_уровень_знаний_ (
	id integer PRIMARY KEY,
	название character varying(50) NULL,
	активность character varying(50) NULL,
	"Сорт." integer NULL,
	"Дата изм." character varying(50) NULL,
	дата character varying(50) NULL,
	"Среды разработки" character varying(50) NOT NULL,
	"Уровень знаний" character varying(50) NOT NULL,
	FOREIGN KEY ("Среды разработки") REFERENCES dds_ira.среды_разработки (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id)
);

--Создание таблицы "технологии_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS dds_ira.технологии_и_уровень_знаний_сотру (
	id integer PRIMARY KEY,
	название text NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL,
	дата text NULL,
	технологии text NOT NULL,
	"Уровень знаний" text NOT NULL,
	FOREIGN KEY (технологии) REFERENCES dds_ira.технологии (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id)
);

--Создание таблицы "типы_систем_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS dds_ira.типы_систем_и_уровень_знаний_сотру (
	id integer PRIMARY KEY,
	название character varying(50) NULL,
	активность character varying(50) NULL,
	"Сорт." integer NULL,
	"Дата изм." character varying(50) NULL,
	дата character varying(50) NULL,
	"Типы систем" character varying(64) NOT NULL,
	"Уровень знаний" character varying(50) NOT NULL,
	FOREIGN KEY ("Типы систем") REFERENCES dds_ira.типы_систем (id),
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id)
);

--Создание таблицы "фреймворки_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS dds_ira.фреймворки_и_уровень_знаний_сотру (
	id integer PRIMARY KEY,
	название text NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL,
	дата text NULL,
	"Уровень знаний" text NOT NULL,
	фреймворки text NOT NULL,
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY (фреймворки) REFERENCES dds_ira.фреймворки (id)
);

--Создание таблицы "языки_пользователей"
CREATE TABLE IF NOT EXISTS dds_ira.языки_пользователей (
	id integer PRIMARY KEY,
	название text NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL,
	язык text NOT NULL,
	"Уровень знаний ин. языка" text NULL,
	FOREIGN KEY (язык) REFERENCES dds_ira.языки (id)
);

--Создание таблицы "языки_программирования_и_уровень"
CREATE TABLE IF NOT EXISTS dds_ira.языки_программирования_и_уровень (
	id integer PRIMARY KEY,
	название text NULL,
	активность text NULL,
	"Сорт." integer NULL,
	"Дата изм." text NULL,
	дата text NULL,
	"Уровень знаний" text NOT NULL,
	"Языки программирования" text NOT NULL,
	FOREIGN KEY ("Уровень знаний") REFERENCES dds_ira.уровни_знаний (id),
	FOREIGN KEY ("Языки программирования") REFERENCES dds_ira.языки_программирования (id)
);
