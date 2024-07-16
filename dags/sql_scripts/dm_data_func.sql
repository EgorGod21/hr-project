CREATE OR REPLACE FUNCTION сотрудники_дар_dm_egor()
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    WITH classified_roles AS (
        SELECT
            id,
            активность,
            фамилия,
            имя,
            CASE
                WHEN lower("должность") ~ '.*(системный аналитик).*' THEN 'системный аналитик'
                WHEN lower("должность") ~ '.*(бизнес-аналитик).*' THEN 'бизнес-аналитик'
                WHEN lower("должность") ~ '.*(инженер данных).*' THEN 'инженер данных'
                WHEN lower("должность") ~ '.*(разработчик).*' THEN 'разработчик'
                WHEN lower("должность") ~ '.*(тестировщ).*' OR lower("должность") ~ '.*(тестированию).*' THEN 'тестировщик'
                WHEN lower("должность") ~ '.*(архитектор).*' THEN 'архитектор'
                WHEN lower("должность") ~ '.*(руководитель проектов).*' THEN 'руководитель проектов'
                ELSE NULL
            END AS "должность",
            цфо
        FROM dds_egor.сотрудники_дар
        WHERE цфо = 'DAR'
			AND активность = 'Да'
    )
    INSERT INTO dm_egor.сотрудники_дар
    SELECT
        t1.id,
        t1.фамилия,
        t1.имя,
        t1."должность"
    FROM classified_roles t1
    WHERE t1."должность" IS NOT NULL
	AND t1.активность = 'Да'
	AND NOT EXISTS (
        SELECT 1 FROM dm_egor.сотрудники_дар t2 WHERE t1.id = t2.ID_сотрудника
    );
END;
$$;

CREATE OR REPLACE FUNCTION уровни_знаний_dm_egor()
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO dm_egor.уровни_знаний
    SELECT
       t1.id,
       t1.название
    FROM dds_egor.уровни_знаний t1
	WHERE NOT EXISTS (
	SELECT 1 FROM dm_egor.уровни_знаний t2 WHERE t1.id = t2.ID_уровня
	)
    AND t1.название != 'Использовал на проекте';
END;
$$;

CREATE OR REPLACE FUNCTION группы_навыков_dm_egor()
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
	CREATE UNIQUE INDEX IF NOT EXISTS уникальный_группа_навыков
	ON dm_egor.группы_навыков ("Группа_навыков");
    INSERT INTO dm_egor.группы_навыков ("Группа_навыков")
	VALUES
	('Инструменты'),
	('Базы данных'),
	('Платформы'),
	('Среды разработки'),
	('Типы систем'),
	('Фреймворки'),
	('Языки программирования'),
	('Технологии')
    ON CONFLICT ("Группа_навыков") DO NOTHING;
END;
$$;

-- заполняет таблицу навыки слоя dm_egor данными из указанной таблицы
CREATE OR REPLACE FUNCTION _навыки_insert_dm_egor(tab_name text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format(
        'INSERT INTO dm_egor.навыки
        SELECT
            t1.id,
            t1.название
        FROM dds_egor.%I t1
		WHERE t1.название != ''Другое''
		AND NOT EXISTS (
            SELECT 1 FROM dm_egor.навыки t2 WHERE t1.id = t2.ID_навыка
        );',
        tab_name
    );
END;
$$;

-- заполняет таблицу навыки слоя dm_egor
CREATE OR REPLACE FUNCTION навыки_dm_egor()
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
    tab_name text;
    tab_names text[] := ARRAY[
        'инструменты', 'базы_данных', 'платформы',
        'среды_разработки', 'типы_систем', 'фреймворки',
        'языки_программирования', 'технологии'
    ];
BEGIN
    FOREACH tab_name IN ARRAY tab_names
    LOOP
        PERFORM _навыки_insert_dm_egor(tab_name);
    END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION группы_навыков_и_уровень_знаний_сотруд_dm_egor(
    main_table text,
	field_fk1 text,
    table_fk1 text,
    p_group_number INT
) RETURNS void AS $$
BEGIN
    EXECUTE format(
        'WITH ranked_skills AS (
            SELECT
                t1.id,
                t1."Дата изм.",
                CASE
                    WHEN t1.дата IS NULL THEN DATE(t1."Дата изм.")
                    ELSE t1.дата
                END AS Дата,
                t1."User ID",
                t1.%I AS "Навыки",
                -- меняем id Использовал на проекте на id Novice
                CASE
                    WHEN t1."Уровень знаний" = 283045 THEN 115637
                    ELSE t1."Уровень знаний"
                END AS "Уровень знаний",
                %L::INT AS Группа_навыков,
                ROW_NUMBER() OVER (
                    PARTITION BY "User ID", t1.%I, t1.дата, t1."Дата изм."
                    ORDER BY
                    CASE t2.Название
                        WHEN ''Novice'' THEN 1
                        WHEN ''Junior'' THEN 2
                        WHEN ''Middle'' THEN 3
                        WHEN ''Senior'' THEN 4
                        WHEN ''Expert'' THEN 5
                        WHEN ''Использовал на проекте'' THEN 6
                        ELSE 0
                    END DESC
                ) AS rank
            FROM dds_egor.%I t1
            INNER JOIN dm_egor.уровни_знаний t2 ON t2.ID_уровня = t1."Уровень знаний"
            INNER JOIN dds_egor.%I t3 ON t1.%I = t3.id
            WHERE t1.активность = ''Да'' AND t3.название != ''Другое''
        )
        INSERT INTO dm_egor.группы_навыков_и_уровень_знаний_сотруд
		SELECT rs.id,
               rs."Дата изм.",
               rs.Дата,
               rs."User ID",
			   rs.Группа_навыков,
               rs."Навыки",
               rs."Уровень знаний"
        FROM ranked_skills rs
        WHERE rs.rank = 1
		AND EXISTS (
            SELECT 1 FROM dm_egor.сотрудники_дар sd WHERE sd.ID_сотрудника = rs."User ID"
        )
        AND NOT EXISTS (
            SELECT 1 FROM dm_egor.группы_навыков_и_уровень_знаний_сотруд t2 WHERE rs.id = t2.id
        );',
        field_fk1, p_group_number, field_fk1, main_table, table_fk1, field_fk1
    );
END;
$$ LANGUAGE plpgsql;