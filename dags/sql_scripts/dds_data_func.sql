CREATE OR REPLACE FUNCTION сотрудники_дар_dds()
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO dds.сотрудники_дар
    SELECT 
        t1.id, 
        CASE 
            WHEN t1."Дата рождения" ~ '^([0-3][0-9])\.([0-1][0-9])\.([1-2][09][0-9][0-9])$' THEN TO_DATE(t1."Дата рождения", 'DD.MM.YYYY') 
            ELSE NULL 
        END AS "Дата рождения",
        COALESCE(NULLIF(t1.активность, ''), 'да') AS активность,
        NULLIF(t1.пол, '') AS пол,
        NULLIF(t1.фамилия, '') AS фамилия,
        NULLIF(t1.имя, '') AS имя,
        CASE 
            WHEN t1."Последняя авторизация" ~ '^([0-3][0-9])\.([0-1][0-9])\.([1-2][09][0-9][0-9]) (2[0-3]|[01]?[0-9]):[0-5][0-9]:[0-5][0-9]$' THEN TO_TIMESTAMP(t1."Последняя авторизация", 'DD.MM.YYYY HH24:MI:SS') 
            ELSE NULL 
        END AS "Последняя авторизация",
        NULLIF(t1.должность, '') AS должность,
        NULLIF(t1.цфо, '') AS цфо,
        CASE 
            WHEN t1."Дата регистрации" ~ '^([0-3][0-9])\.([0-1][0-9])\.([1-2][09][0-9][0-9])$' THEN TO_DATE(t1."Дата регистрации", 'DD.MM.YYYY') 
            ELSE NULL 
        END AS "Дата регистрации",
        CASE 
            WHEN t1."Дата изменения" ~ '^([0-3][0-9])\.([0-1][0-9])\.([1-2][09][0-9][0-9]) (2[0-3]|[01]?[0-9]):[0-5][0-9]:[0-5][0-9]$' THEN TO_TIMESTAMP(t1."Дата изменения", 'DD.MM.YYYY HH24:MI:SS') 
            ELSE CURRENT_TIMESTAMP(0)
        END AS "Дата изменения",
        NULLIF(regexp_replace(t1.подразделения, '(\. ){2,}', '', 'g'), '') AS подразделения,
        NULLIF(t1."E-Mail", '') AS "E-Mail",
        NULLIF(t1.логин, '') AS логин,
        NULLIF(t1.компания, '') AS компания,
        NULLIF(t1."Город проживания", '') AS "Город проживания"
    FROM ods.сотрудники_дар t1
    WHERE t1.id IS NOT NULL 
	AND NOT EXISTS (
        SELECT 1 FROM dds.сотрудники_дар t2 WHERE t1.id = t2.id
    );
END;
$$;

CREATE OR REPLACE FUNCTION insert_4_col_dds(tab_name text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format(
        'INSERT INTO dds.%I
        SELECT 
            t1.id, 
            t1.название,
            COALESCE(NULLIF(t1.активность, ''''), ''да'') AS активность,
            CASE 
                WHEN t1."Дата изм." ~ ''^([0-3][0-9])\.([0-1][0-9])\.([1-2][09][0-9][0-9]) (2[0-3]|[01]?[0-9]):[0-5][0-9]:[0-5][0-9]$'' THEN TO_TIMESTAMP(t1."Дата изм.", ''DD.MM.YYYY HH24:MI:SS'') 
                ELSE CURRENT_TIMESTAMP(0) 
            END AS "Дата изм."
        FROM ods.%I t1
        WHERE t1.id IS NOT NULL
        AND t1.название IS NOT NULL 
        AND t1.название <> ''''
        AND NOT EXISTS (
            SELECT 1 FROM dds.%I t2 WHERE t1.id = t2.id
        );',
        tab_name, tab_name, tab_name
    );

    EXECUTE format(
        'INSERT INTO dds_er.%I
			SELECT 
			    t1.id, 
			    t1.название::TEXT,
			    t1.активность::TEXT,
			    t1."Дата изм."::TEXT
			FROM ods.%I t1
			WHERE NOT EXISTS (
			        SELECT 1 
			        FROM dds.%I t2 
			        WHERE t1.id != t2.id
			    );',
        tab_name || '_er', tab_name, tab_name
    );
END;
$$;

CREATE OR REPLACE FUNCTION create_insert_4_col_dds()
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
    tab_name text;
    tab_names text[] := ARRAY[
        'инструменты', 'уровни_знаний', 'базы_данных', 'языки', 
        'уровни_владения_ин', 'уровень_образования', 'отрасли', 
        'уровни_знаний_в_отрасли', 'предметная_область', 
        'уровни_знаний_в_предметной_област', 'платформы', 
        'среды_разработки', 'типы_систем', 'фреймворки', 
        'языки_программирования', 'технологии'
    ];
BEGIN
    FOREACH tab_name IN ARRAY tab_names
    LOOP
        PERFORM insert_4_col_dds(tab_name);
    END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION insert_7_col_dds(
    main_table text,
    field_fk1 text,
    table_fk1 text,
    field_fk2 text,
    table_fk2 text
)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format(
        'INSERT INTO dds.%I
        SELECT 
            t1.id,
            CASE
                WHEN regexp_replace(t1.название, ''\D'', '''', ''g'') <> '''' THEN regexp_replace(t1.название, ''\D'', '''', ''g'')::INT 
                ELSE NULL
            END AS "User ID",
            COALESCE(NULLIF(t1.активность, ''''), ''да'') AS активность,
            CASE 
                WHEN t1."Дата изм." ~ ''^([0-3][0-9])\.([0-1][0-9])\.([1-2][09][0-9][0-9]) (2[0-3]|[01]?[0-9]):[0-5][0-9]:[0-5][0-9]$'' THEN TO_TIMESTAMP(t1."Дата изм.", ''DD.MM.YYYY HH24:MI:SS'') 
                ELSE CURRENT_TIMESTAMP(0)
            END AS "Дата изм.",
            CASE 
                WHEN t1.дата ~ ''^([0-3][0-9])\.([0-1][0-9])\.([1-2][09][0-9][0-9])$'' THEN TO_DATE(t1.дата, ''DD.MM.YYYY'') 
                ELSE NULL 
            END AS дата,
            CASE
                WHEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'') <> '''' THEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'')::INT
                ELSE NULL
            END AS %I,
            CASE
                WHEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'') <> '''' THEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'')::INT 
                ELSE NULL
            END AS %I
        FROM ods.%I t1
        WHERE t1.id IS NOT NULL
        AND (CASE
                WHEN regexp_replace(t1.название, ''\D'', '''', ''g'') <> '''' THEN regexp_replace(t1.название, ''\D'', '''', ''g'')::INT 
                ELSE NULL
            END) IS NOT NULL
        AND (CASE
                WHEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'') <> '''' THEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'')::INT 
                ELSE NULL
            END) IS NOT NULL 
        AND (CASE
                WHEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'') <> '''' THEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'')::INT 
                ELSE NULL
            END) IS NOT NULL 
        AND EXISTS (  
            SELECT 1 FROM dds.сотрудники_дар sd WHERE sd.id = (CASE
                    WHEN regexp_replace(t1.название, ''\D'', '''', ''g'') <> '''' THEN regexp_replace(t1.название, ''\D'', '''', ''g'')::INT 
                    ELSE NULL
                END)
        )
        AND EXISTS (  
            SELECT 1 FROM dds.%I fk1 WHERE fk1.id = (CASE
                    WHEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'') <> '''' THEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'')::INT 
                    ELSE NULL
                END)
        )
        AND EXISTS (  
            SELECT 1 FROM dds.%I fk2 WHERE fk2.id = (CASE
                    WHEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'') <> '''' THEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'')::INT 
                    ELSE NULL
                END)
        )
        AND NOT EXISTS (  
            SELECT 1 FROM dds.%I t2 WHERE t1.id = t2.id
        );',
        main_table, field_fk1, field_fk1, field_fk1, field_fk2, field_fk2, field_fk2,
        main_table, field_fk1, field_fk1, field_fk2, field_fk2,
        table_fk1, field_fk1, field_fk1, table_fk2, field_fk2, field_fk2,
        main_table
    );

    EXECUTE format(
        'INSERT INTO dds_er.%I
        SELECT 
            t1.id,
            t1.название::TEXT,
            t1.активность::TEXT,
            t1."Дата изм."::TEXT, 
            t1.дата::TEXT,
            t1.%I::TEXT,
            t1.%I::TEXT
        FROM ods.%I t1
        WHERE NOT EXISTS (
            SELECT 1 
            FROM dds.%I t2 
            WHERE t1.id = t2.id
        );',
        main_table || '_er', field_fk1, field_fk2,
        main_table, main_table
    );
END;
$$;

CREATE OR REPLACE FUNCTION insert_7_col_uid_int_dds(
    main_table text,
    field_fk1 text,
    table_fk1 text,
    field_fk2 text,
    table_fk2 text
)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format(
        'INSERT INTO dds.%I
        SELECT 
            t1.id,
            t1."User ID",
            COALESCE(NULLIF(t1.активность, ''''), ''да'') AS активность,
            CASE 
                WHEN t1."Дата изм." ~ ''^([0-3][0-9])\.([0-1][0-9])\.([1-2][09][0-9][0-9]) (2[0-3]|[01]?[0-9]):[0-5][0-9]:[0-5][0-9]$'' THEN TO_TIMESTAMP(t1."Дата изм.", ''DD.MM.YYYY HH24:MI:SS'') 
                ELSE CURRENT_TIMESTAMP(0)
            END AS "Дата изм.",
            CASE 
                WHEN t1.дата ~ ''^([0-3][0-9])\.([0-1][0-9])\.([1-2][09][0-9][0-9])$'' THEN TO_DATE(t1.дата, ''DD.MM.YYYY'') 
                ELSE NULL 
            END AS дата,
            CASE
                WHEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'') <> '''' THEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'')::INT
                ELSE NULL
            END AS %I,
            CASE
                WHEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'') <> '''' THEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'')::INT 
                ELSE NULL
            END AS %I
        FROM ods.%I t1
        WHERE t1.id IS NOT NULL
        AND t1."User ID" IS NOT NULL
        AND (CASE
                WHEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'') <> '''' THEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'')::INT 
                ELSE NULL
            END) IS NOT NULL 
        AND (CASE
                WHEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'') <> '''' THEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'')::INT 
                ELSE NULL
            END) IS NOT NULL 
        AND EXISTS (  
            SELECT 1 FROM dds.сотрудники_дар sd WHERE sd.id = t1."User ID"
        )
        AND EXISTS (  
            SELECT 1 FROM dds.%I fk1 WHERE fk1.id = (CASE
                    WHEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'') <> '''' THEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'')::INT 
                    ELSE NULL
                END)
        )
        AND EXISTS (  
            SELECT 1 FROM dds.%I fk2 WHERE fk2.id = (CASE
                    WHEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'') <> '''' THEN regexp_replace(t1.%I, ''.*\[(\d+)\].*'', ''\1'')::INT 
                    ELSE NULL
                END)
        )
        AND NOT EXISTS (  
            SELECT 1 FROM dds.%I t2 WHERE t1.id = t2.id
        );',
        main_table, field_fk1, field_fk1, field_fk1, field_fk2, field_fk2, field_fk2,
        main_table, field_fk1, field_fk1, field_fk2, field_fk2,
        table_fk1, field_fk1, field_fk1, table_fk2, field_fk2, field_fk2,
        main_table
    );
	 EXECUTE format(
        'INSERT INTO dds_er.%I
        SELECT 
            t1.id,
            t1."User ID"::TEXT,
            t1.активность::TEXT,
            t1."Дата изм."::TEXT, 
            t1.дата::TEXT,
            t1.%I::TEXT,
            t1.%I::TEXT
        FROM ods.%I t1
        WHERE NOT EXISTS (
            SELECT 1 
            FROM dds.%I t2 
            WHERE t1.id = t2.id
        );',
        main_table || '_er', field_fk1, field_fk2,
        main_table, main_table
    );
END;
$$;

CREATE OR REPLACE FUNCTION языки_пользователей_dds()
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO dds.языки_пользователей
    SELECT 
        t1.id,
		CASE
    		WHEN regexp_replace(t1.название, '\D', '', 'g') <> '' THEN regexp_replace(t1.название, '\D', '', 'g')::INT 
    		ELSE NULL
		END AS "User ID",
        COALESCE(NULLIF(t1.активность, ''), 'да') AS активность,
        CASE 
            WHEN t1."Дата изм." ~ '^([0-3][0-9])\.([0-1][0-9])\.([1-2][09][0-9][0-9]) (2[0-3]|[01]?[0-9]):[0-5][0-9]:[0-5][0-9]$' THEN TO_TIMESTAMP(t1."Дата изм.", 'DD.MM.YYYY HH24:MI:SS') 
            ELSE CURRENT_TIMESTAMP(0)
        END AS "Дата изм.",
		CASE
    		WHEN regexp_replace(t1.язык, '.*\[(\d+)\].*', '\1') <> '' THEN regexp_replace(t1.язык, '.*\[(\d+)\].*', '\1')::INT
    		ELSE NULL
		END AS язык,
		CASE
    		WHEN regexp_replace(t1."Уровень знаний ин. языка", '.*\[(\d+)\].*', '\1') <> '' THEN regexp_replace(t1."Уровень знаний ин. языка", '.*\[(\d+)\].*', '\1')::INT 
    		ELSE NULL
		END AS "Уровень знаний ин. языка"
    FROM ods.языки_пользователей t1
    WHERE t1.id IS NOT NULL
	AND (CASE
            WHEN regexp_replace(t1.название, '\D', '', 'g') <> '' THEN regexp_replace(t1.название, '\D', '', 'g')::INT 
            ELSE NULL
        END) IS NOT NULL
	AND (CASE
            WHEN regexp_replace(t1."Уровень знаний ин. языка", '.*\[(\d+)\].*', '\1') <> '' THEN regexp_replace(t1."Уровень знаний ин. языка", '.*\[(\d+)\].*', '\1')::INT 
            ELSE NULL
        END) IS NOT NULL 
	AND (CASE
            WHEN regexp_replace(t1.язык, '.*\[(\d+)\].*', '\1') <> '' THEN regexp_replace(t1.язык, '.*\[(\d+)\].*', '\1')::INT 
            ELSE NULL
        END) IS NOT NULL 
    AND EXISTS (  
        SELECT 1 FROM dds.сотрудники_дар sd WHERE sd.id = (CASE
    WHEN regexp_replace(t1.название, '\D', '', 'g') <> '' THEN regexp_replace(t1.название, '\D', '', 'g')::INT
    ELSE NULL
END)
    )
	AND EXISTS (  
        SELECT 1 FROM dds.уровни_владения_ин uz WHERE uz.id = (CASE
            WHEN regexp_replace(t1."Уровень знаний ин. языка", '.*\[(\d+)\].*', '\1') <> '' THEN regexp_replace(t1."Уровень знаний ин. языка", '.*\[(\d+)\].*', '\1')::INT
            ELSE NULL
        END)
    )
	AND EXISTS (  
        SELECT 1 FROM dds.языки db WHERE db.id = (CASE
            WHEN regexp_replace(t1.язык, '.*\[(\d+)\].*', '\1') <> '' THEN regexp_replace(t1.язык, '.*\[(\d+)\].*', '\1')::INT
            ELSE NULL
        END)
    )
    AND NOT EXISTS (  
        SELECT 1 FROM dds.языки_пользователей t2 WHERE t1.id = t2.id
    );
	INSERT INTO dds_er.языки_пользователей_er
        SELECT 
            t1.id,
            t1.название::TEXT,
            t1.активность::TEXT,
            t1."Дата изм."::TEXT, 
            t1.язык::TEXT,
            t1."Уровень знаний ин. языка"::TEXT
        FROM ods.языки_пользователей t1
        WHERE NOT EXISTS (
            SELECT 1 
            FROM dds.языки_пользователей t2 
            WHERE t1.id = t2.id
        );
END;
$$;

CREATE OR REPLACE FUNCTION сертификаты_пользователей_dds()
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO dds.сертификаты_пользователей
    SELECT 
        t1.id,
        t1."User ID",
        COALESCE(NULLIF(t1.активность, ''), 'да') AS активность,
        CASE 
            WHEN t1."Дата изм." ~ '^([0-3][0-9])\.([0-1][0-9])\.([1-2][09][0-9][0-9]) (2[0-3]|[01]?[0-9]):[0-5][0-9]:[0-5][0-9]$' THEN TO_TIMESTAMP(t1."Дата изм.", 'DD.MM.YYYY HH24:MI:SS') 
            ELSE CURRENT_TIMESTAMP(0)
        END AS "Дата изм.",
        CASE 
            WHEN CAST(t1."Год сертификата" as TEXT) ~ '^([1-2][09][0-9][0-9])$' THEN t1."Год сертификата"
            ELSE NULL
        END AS "Год сертификата",
        NULLIF(t1."Наименование сертификата", '') AS "Наименование сертификата",
        NULLIF(t1."Организация, выдавшая сертификат", '') AS "Организация, выдавшая сертификат"
    FROM ods.сертификаты_пользователей t1
    WHERE t1.id IS NOT NULL
    AND t1."User ID" IS NOT NULL
    AND NULLIF(t1."Наименование сертификата", '') IS NOT NULL 
    AND EXISTS (  
        SELECT 1 FROM dds.сотрудники_дар sd WHERE sd.id = t1."User ID"
    )
    AND NOT EXISTS (  
        SELECT 1 FROM dds.сертификаты_пользователей t2 WHERE t1.id = t2.id
    );
	INSERT INTO dds_er.сертификаты_пользователей_er
        SELECT 
            t1.id,
            t1."User ID"::TEXT,
            t1.активность::TEXT,
            t1."Дата изм."::TEXT, 
            t1."Год сертификата"::TEXT,
            t1."Наименование сертификата"::TEXT,
			t1."Организация, выдавшая сертификат"::TEXT
        FROM ods.сертификаты_пользователей t1
        WHERE NOT EXISTS (
            SELECT 1 
            FROM dds.сертификаты_пользователей t2 
            WHERE t1.id = t2.id
        );
END;
$$;

CREATE OR REPLACE FUNCTION образование_пользователей_dds()
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO dds.образование_пользователей
        SELECT 
            t1.id,
            t1."User ID",
            COALESCE(NULLIF(t1.активность, ''), 'да') AS активность,
            CASE 
                WHEN t1."Дата изм." ~ '^([0-3][0-9])\.([0-1][0-9])\.([1-2][09][0-9][0-9]) (2[0-3]|[01]?[0-9]):[0-5][0-9]:[0-5][0-9]$' THEN TO_TIMESTAMP(t1."Дата изм.", 'DD.MM.YYYY HH24:MI:SS') 
                ELSE CURRENT_TIMESTAMP(0)
            END AS "Дата изм.",
            CASE
                WHEN regexp_replace(t1."Уровень образование", '.*\[(\d+)\].*', '\1') <> '' THEN regexp_replace(t1."Уровень образование", '.*\[(\d+)\].*', '\1')::INT
                ELSE NULL
            END AS "Уровень образование",
            NULLIF(t1."Название учебного заведения", '') AS "Название учебного заведения",
			NULLIF(t1."Фиктивное название", '') AS "Фиктивное название",
			NULLIF(t1."Факультет, кафедра", '') AS "Факультет, кафедра",
			NULLIF(LOWER(t1.специальность), '') AS специальность,
			NULLIF(LOWER(t1.квалификация), '') AS квалификация,
			CASE 
                WHEN CAST(t1."Год окончания" as TEXT) ~ '^[1-2][09][0-9][0-9]$' THEN t1."Год окончания" 
                ELSE NULL
            END AS "Год окончания"
        FROM ods.образование_пользователей t1
        WHERE t1.id IS NOT NULL
        AND t1."User ID" IS NOT NULL
        AND (CASE
                WHEN regexp_replace(t1."Уровень образование", '.*\[(\d+)\].*', '\1') <> '' THEN regexp_replace(t1."Уровень образование", '.*\[(\d+)\].*', '\1')::INT 
                ELSE NULL
            END) IS NOT NULL 
        AND EXISTS (  
            SELECT 1 FROM dds.сотрудники_дар sd WHERE sd.id = t1."User ID"
        )
        AND EXISTS (  
            SELECT 1 FROM dds.уровень_образования fk1 WHERE fk1.id = (CASE
                    WHEN regexp_replace(t1."Уровень образование", '.*\[(\d+)\].*', '\1') <> '' THEN regexp_replace(t1."Уровень образование", '.*\[(\d+)\].*', '\1')::INT 
                    ELSE NULL
                END)
        )
        AND NOT EXISTS (  
            SELECT 1 FROM dds.образование_пользователей t2 WHERE t1.id = t2.id
        );
	INSERT INTO dds_er.образование_пользователей_er
        SELECT 
            t1.id,
            t1."User ID"::TEXT,
            t1.активность::TEXT,
            t1."Дата изм."::TEXT, 
            t1."Уровень образование"::TEXT,
            t1."Название учебного заведения"::TEXT,
            t1."Фиктивное название"::TEXT,
            t1."Факультет, кафедра"::TEXT,
            t1.специальность::TEXT,
            t1.квалификация::TEXT,
            t1."Год окончания"::TEXT
        FROM ods.образование_пользователей t1
        WHERE NOT EXISTS (
            SELECT 1 
            FROM dds.образование_пользователей t2 
            WHERE t1.id = t2.id
        );

		UPDATE dds."образование_пользователей"
			SET 
			    квалификация = CASE
			        WHEN специальность IN ('бакалавр', 'специалист', 'магистр') AND квалификация IS NULL THEN специальность
			        ELSE квалификация
			    END,
			    специальность = CASE
			        WHEN специальность IN ('бакалавр', 'специалист', 'магистр') AND квалификация IS NULL THEN NULL
			        ELSE специальность
			    END
			WHERE специальность IN ('бакалавр', 'специалист', 'магистр') AND квалификация IS NULL;
END;
$$;
