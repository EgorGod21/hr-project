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
        t1.активность,
        t1.фамилия,
        t1.имя,
        t1."должность",
        t1.цфо
    FROM classified_roles t1
    WHERE t1."должность" IS NOT NULL
	AND t1.активность = 'Да'
	AND NOT EXISTS (
        SELECT 1 FROM dm_egor.сотрудники_дар t2 WHERE t1.id = t2.id
    );
END;
$$;

CREATE OR REPLACE FUNCTION insert_4_col_dm_egor(tab_name text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format(
        'INSERT INTO dm_egor.%I
        SELECT
            t1.id,
            t1.название
        FROM dds_egor.%I t1
		WHERE NOT EXISTS (
            SELECT 1 FROM dm_egor.%I t2 WHERE t1.id = t2.id
        );',
        tab_name, tab_name, tab_name
    );
END;
$$;

CREATE OR REPLACE FUNCTION create_insert_4_col_dm_egor()
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
    tab_name text;
    tab_names text[] := ARRAY[
        'инструменты', 'уровни_знаний', 'базы_данных', 'платформы',
        'среды_разработки', 'типы_систем', 'фреймворки',
        'языки_программирования', 'технологии'
    ];
BEGIN
    FOREACH tab_name IN ARRAY tab_names
    LOOP
        PERFORM insert_4_col_dm_egor(tab_name);
    END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION insert_7_col_uid_int_dm_egor(
    main_table text,
    field_fk1 text,
    table_fk1 text
)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format(
        'INSERT INTO dm_egor.%I
        SELECT
            t1.id,
            t1."User ID",
            t1.активность,
            t1."Дата изм.",
            CASE
                WHEN t1.дата IS NULL THEN DATE(t1."Дата изм.")
                ELSE t1.дата
            END AS дата,
            t1.%I,
            t1."Уровень знаний"
        FROM dds_egor.%I t1
        WHERE t1.активность = ''Да''
        AND EXISTS (
            SELECT 1 FROM dm_egor.сотрудники_дар sd WHERE sd.id = t1."User ID"
        )
        AND EXISTS (
            SELECT 1 FROM dm_egor.%I fk1 WHERE fk1.id = t1.%I
        )
        AND EXISTS (
            SELECT 1 FROM dm_egor.уровни_знаний fk2 WHERE fk2.id = t1."Уровень знаний"
        )
        AND NOT EXISTS (
            SELECT 1 FROM dm_egor.%I t2 WHERE t1.id = t2.id
        );',
        main_table, field_fk1, main_table, table_fk1, field_fk1, main_table
    );
END;
$$;