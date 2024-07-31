-- Создание схемы "ods"
CREATE SCHEMA IF NOT EXISTS ods;

--Создание таблицы "базы_данных"
CREATE TABLE IF NOT EXISTS ods.базы_данных (
	название varchar(50) NULL,
	активность varchar(50) NULL,
	"Сорт." int4 NULL,
	"Дата изм." varchar(50) NULL,
	id int4 NULL
);

--Создание таблицы "базы_данных_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS ods.базы_данных_и_уровень_знаний_сотру (
	название varchar(50) NULL,
	активность varchar(50) NULL,
	"Сорт." int4 NULL,
	"Дата изм." varchar(50) NULL,
	id int4 NULL,
	"Базы данных" varchar(50) NULL,
	дата varchar(50) NULL,
	"Уровень знаний" varchar(50) NULL
);

--Создание таблицы "инструменты"
CREATE TABLE IF NOT EXISTS ods.инструменты (
	название varchar(50) NULL,
	активность varchar(50) NULL,
	"Сорт." int4 NULL,
	"Дата изм." varchar(50) NULL,
	id int4 NULL
);

--Создание таблицы "инструменты_и_уровень_знаний_сотр"
CREATE TABLE IF NOT EXISTS ods.инструменты_и_уровень_знаний_сотр (
	название varchar(50) NULL,
	активность varchar(50) NULL,
	"Сорт." int4 NULL,
	"Дата изм." varchar(50) NULL,
	id int4 NULL,
	дата varchar(50) NULL,
	инструменты varchar(64) NULL,
	"Уровень знаний" varchar(50) NULL
);

--Создание таблицы "образование_пользователей"
CREATE TABLE IF NOT EXISTS ods.образование_пользователей (
	"User ID" int4 NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL,
	"Уровень образование" text NULL,
	"Название учебного заведения" text NULL,
	"Фиктивное название" text NULL,
	"Факультет, кафедра" text NULL,
	специальность text NULL,
	квалификация text NULL,
	"Год окончания" int4 NULL
);

--Создание таблицы "опыт_сотрудника_в_отраслях"
CREATE TABLE IF NOT EXISTS ods.опыт_сотрудника_в_отраслях (
	"User ID" int4 NULL,
	активность varchar(50) NULL,
	"Сорт." int4 NULL,
	"Дата изм." varchar(50) NULL,
	id int4 NULL,
	дата varchar(50) NULL,
	отрасли varchar(50) NULL,
	"Уровень знаний в отрасли" varchar(128) NULL
);

--Создание таблицы "опыт_сотрудника_в_предметных_обла"
CREATE TABLE IF NOT EXISTS ods.опыт_сотрудника_в_предметных_обла (
	"User ID" int4 NULL,
	активность varchar(50) NULL,
	"Сорт." int4 NULL,
	"Дата изм." varchar(50) NULL,
	id int4 NULL,
	дата varchar(50) NULL,
	"Предментые области" varchar(50) NULL,
	"Уровень знаний в предметной облас" varchar(128) NULL
);

--Создание таблицы "отрасли"
CREATE TABLE IF NOT EXISTS ods.отрасли (
	название varchar(50) NULL,
	активность varchar(50) NULL,
	"Сорт." int4 NULL,
	"Дата изм." varchar(50) NULL,
	id int4 NULL
);

--Создание таблицы "платформы"
CREATE TABLE IF NOT EXISTS ods.платформы (
	название varchar(50) NULL,
	активность varchar(50) NULL,
	"Сорт." int4 NULL,
	"Дата изм." varchar(50) NULL,
	id int4 NULL
);

--Создание таблицы "платформы_и_уровень_знаний_сотруд"
CREATE TABLE IF NOT EXISTS ods.платформы_и_уровень_знаний_сотруд (
	"User ID" int4 NULL,
	активность varchar(50) NULL,
	"Сорт." int4 NULL,
	"Дата изм." varchar(50) NULL,
	id int4 NULL,
	дата varchar(50) NULL,
	платформы varchar(64) NULL,
	"Уровень знаний" varchar(50) NULL
);

--Создание таблицы "предметная_область"
CREATE TABLE IF NOT EXISTS ods.предметная_область (
	название varchar(50) NULL,
	активность varchar(50) NULL,
	"Сорт." int4 NULL,
	"Дата изм." varchar(50) NULL,
	id int4 NULL
);

--Создание таблицы "резюмедар"
CREATE TABLE IF NOT EXISTS ods.резюмедар (
	"UserID" int4 NULL,
	"ResumeID" int4 NULL,
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
	"Технологии" text NULL
);

--Создание таблицы "сертификаты_пользователей"
CREATE TABLE IF NOT EXISTS ods.сертификаты_пользователей (
	"User ID" int4 NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL,
	"Год сертификата" int4 NULL,
	"Наименование сертификата" text NULL,
	"Организация, выдавшая сертификат" text NULL
);

--Создание таблицы "сотрудники_дар"
CREATE TABLE IF NOT EXISTS ods.сотрудники_дар (
	id int4 NULL,
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
CREATE TABLE IF NOT EXISTS ods.среды_разработки (
	название text NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL
);

--Создание таблицы "среды_разработки_и_уровень_знаний_"
CREATE TABLE IF NOT EXISTS ods.среды_разработки_и_уровень_знаний_ (
	название varchar(50) NULL,
	активность varchar(50) NULL,
	"Сорт." int4 NULL,
	"Дата изм." varchar(50) NULL,
	id int4 NULL,
	дата varchar(50) NULL,
	"Среды разработки" varchar(50) NULL,
	"Уровень знаний" varchar(50) NULL
);

--Создание таблицы "технологии"
CREATE TABLE IF NOT EXISTS ods.технологии (
	название text NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL
);

--Создание таблицы "технологии_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS ods.технологии_и_уровень_знаний_сотру (
	название text NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL,
	дата text NULL,
	технологии text NULL,
	"Уровень знаний" text NULL
);

--Создание таблицы "типы_систем"
CREATE TABLE IF NOT EXISTS ods.типы_систем (
	название text NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL
);

--Создание таблицы "типы_систем_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS ods.типы_систем_и_уровень_знаний_сотру (
	название varchar(50) NULL,
	активность varchar(50) NULL,
	"Сорт." int4 NULL,
	"Дата изм." varchar(50) NULL,
	id int4 NULL,
	дата varchar(50) NULL,
	"Типы систем" varchar(64) NULL,
	"Уровень знаний" varchar(50) NULL
);

--Создание таблицы "уровень_образования"
CREATE TABLE IF NOT EXISTS ods.уровень_образования (
	название text NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL
);

--Создание таблицы "уровни_владения_ин"
CREATE TABLE IF NOT EXISTS ods.уровни_владения_ин (
	название text NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL
);

--Создание таблицы "уровни_знаний"
CREATE TABLE IF NOT EXISTS ods.уровни_знаний (
	название text NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL
);

--Создание таблицы "уровни_знаний_в_отрасли"
CREATE TABLE IF NOT EXISTS ods.уровни_знаний_в_отрасли (
	название text NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL
);

--Создание таблицы "уровни_знаний_в_предметной_област"
CREATE TABLE IF NOT EXISTS ods.уровни_знаний_в_предметной_област (
	название text NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL
);

--Создание таблицы "фреймворки"
CREATE TABLE IF NOT EXISTS ods.фреймворки (
	название text NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL
);

--Создание таблицы "фреймворки_и_уровень_знаний_сотру"
CREATE TABLE IF NOT EXISTS ods.фреймворки_и_уровень_знаний_сотру (
	название text NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL,
	дата text NULL,
	"Уровень знаний" text NULL,
	фреймворки text NULL
);

--Создание таблицы "языки"
CREATE TABLE IF NOT EXISTS ods.языки (
	название text NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL
);

--Создание таблицы "языки_пользователей"
CREATE TABLE IF NOT EXISTS ods.языки_пользователей (
	название text NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL,
	язык text NULL,
	"Уровень знаний ин. языка" text NULL
);

--Создание таблицы "языки_программирования"
CREATE TABLE IF NOT EXISTS ods.языки_программирования (
	название text NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL
);

--Создание таблицы "языки_программирования_и_уровень"
CREATE TABLE IF NOT EXISTS ods.языки_программирования_и_уровень (
	название text NULL,
	активность text NULL,
	"Сорт." int4 NULL,
	"Дата изм." text NULL,
	id int4 NULL,
	дата text NULL,
	"Уровень знаний" text NULL,
	"Языки программирования" text NULL
);