CREATE OR REPLACE FUNCTION сотрудники_дар_dm()
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    WITH classified_roles AS (
        SELECT
            id,
            активность,
            фамилия,
            имя,
            CASE
                WHEN LOWER("должность") ~ '.*системный аналитик(\s|$)' THEN 'Системный аналитик'
                WHEN LOWER("должность") ~ '.*бизнес-аналитик(\s|$)' THEN 'Бизнес-аналитик'
                WHEN LOWER("должность") ~ '.*(инженер данных).*' THEN 'Инженер данных'
                WHEN LOWER("должность") ~ '.*(разработчик).*' THEN 'Разработчик'
                WHEN LOWER("должность") ~ '.*(тестировщ).*' OR LOWER("должность") ~ '.*(тестированию).*' THEN 'Тестировщик'
                WHEN LOWER("должность") ~ '.*(архитектор).*' THEN 'Архитектор'
                WHEN LOWER("должность") ~ '.*(руководитель проектов).*' THEN 'Руководитель проектов'
                ELSE NULL
            END AS "должность",
            цфо
        FROM dds.сотрудники_дар
        WHERE цфо = 'DAR'
			AND активность = 'Да'
    )
    INSERT INTO dm.сотрудники_дар
    SELECT
        t1.id,
        t1.фамилия,
        t1.имя,
        t1."должность"
    FROM classified_roles t1
    WHERE t1."должность" IS NOT NULL
	AND t1.активность = 'Да'
	AND NOT EXISTS (
        SELECT 1 FROM dm.сотрудники_дар t2 WHERE t1.id = t2.ID_сотрудника
    );
END;
$$;

CREATE OR REPLACE FUNCTION уровни_знаний_dm()
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO dm.уровни_знаний
    SELECT
       t1.id,
       t1.название
    FROM dds.уровни_знаний t1
	WHERE NOT EXISTS (
	SELECT 1 FROM dm.уровни_знаний t2 WHERE t1.id = t2.ID_уровня
	)
    AND t1.название != 'Использовал на проекте';
END;
$$;

CREATE OR REPLACE FUNCTION группы_навыков_dm()
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO dm.группы_навыков ("Группа_навыков")
	VALUES
	('Инструменты'),
	('Базы данных'),
	('Платформы'),
	('Среды разработки'),
	('Типы систем'),
	('Фреймворки'),
	('Языки программирования'),
	('Технологии');
END;
$$;

-- заполняет таблицу навыки слоя dm данными из указанной таблицы
CREATE OR REPLACE FUNCTION _навыки_insert_dm(tab_name text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format(
        'INSERT INTO dm.навыки
        SELECT
            t1.id,
            t1.название
        FROM dds.%I t1
		WHERE t1.название != ''Другое''
		AND NOT EXISTS (
            SELECT 1 FROM dm.навыки t2 WHERE t1.id = t2.ID_навыка
        );',
        tab_name
    );
END;
$$;

-- заполняет таблицу навыки слоя dm
CREATE OR REPLACE FUNCTION навыки_dm()
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
        PERFORM _навыки_insert_dm(tab_name);
    END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION группы_навыков_и_уровень_знаний_сотруд_dm(
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
                CASE
                    WHEN t1."дата" IS NULL THEN DATE(t1."Дата изм.")
                    ELSE t1."дата"
                END AS Дата,
                t1."User ID",
                t1.%I AS "Навыки",
                CASE
                    WHEN t1."Уровень знаний" = 283045 THEN 115637
                    ELSE t1."Уровень знаний"
                END AS "Уровень_знаний",
                %L::INT AS Группа_навыков
            FROM dds.%I t1
            INNER JOIN dds.%I t3 ON t1.%I = t3.id
            WHERE t1.активность = ''Да''
              AND t3.название != ''Другое''
        ),
        filtered_data_rank AS (
            SELECT
                *,
                ROW_NUMBER() OVER (
                    PARTITION BY "User ID", rs.Навыки, rs."Дата"
                    ORDER BY
                    rs."Уровень_знаний" DESC
                ) AS rank_1
            FROM ranked_skills rs
        ),
        filtered_data AS (
            SELECT
                *,
                ROW_NUMBER() OVER (
                    PARTITION BY "User ID", fdr.Навыки, fdr."Уровень_знаний"
                    ORDER BY fdr."Дата"
                ) AS rank_2
            FROM filtered_data_rank fdr
            WHERE id NOT IN (
                -- оставляем последний по дате уровень_владения
                SELECT mt1.id
                FROM filtered_data_rank mt1
                JOIN filtered_data_rank mt2
                  ON mt1."User ID" = mt2."User ID"
                 AND mt1.Группа_навыков = mt2.Группа_навыков
                 AND mt1.Навыки = mt2.Навыки
                 AND mt1."Дата" < mt2."Дата"
                 AND mt1."Уровень_знаний" > mt2."Уровень_знаний"
            ) AND fdr.rank_1 = 1
        )
        INSERT INTO dm.группы_навыков_и_уровень_знаний_сотруд
        SELECT
            fd.id,
            fd.Дата,
            fd."User ID",
            fd.Группа_навыков,
            fd."Навыки",
            fd."Уровень_знаний",
            LAG(fd."Дата") OVER (
                PARTITION BY fd."User ID" , fd.Группа_навыков, fd."Навыки"
                ORDER BY fd."Дата"
            ) AS "Дата_предыдущего_грейда",
            LEAD(fd."Дата") OVER (
                PARTITION BY fd."User ID", fd.Группа_навыков, fd."Навыки"
                ORDER BY fd."Дата"
            ) AS "Дата_следующего_грейда"
        FROM filtered_data fd
        WHERE EXISTS (
            SELECT 1 FROM dm.сотрудники_дар sd WHERE sd.ID_сотрудника = fd."User ID"
        )
        AND NOT EXISTS (
            SELECT 1 FROM dm.группы_навыков_и_уровень_знаний_сотруд t2 WHERE fd.id = t2.id
        ) AND fd.rank_2 = 1;',
        field_fk1, p_group_number, main_table, table_fk1, field_fk1
    );
END;
$$ LANGUAGE plpgsql;
