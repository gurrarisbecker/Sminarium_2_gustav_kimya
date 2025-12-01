WITH base AS (
    SELECT
        cl.course_code,
        ci.instance_id,
        cl.hp,
        ci.study_period,
        ci.study_year,
        e.employment_id,
        CONCAT(p.first_name, ' ', p.last_name) AS teacher_name,
        ta.activity_name,
        (pa.planned_hours * COALESCE(ta.factor, 1)) AS hours
    FROM course_instance       ci
    JOIN course_layout         cl ON cl.course_layout_id    = ci.course_layout_id
    JOIN planned_activity      pa ON pa.instance_id         = ci.instance_id
    JOIN teaching_activity     ta ON ta.teaching_activity_id = pa.teaching_activity_id
    JOIN planned_employee      pe ON pe.planned_activity_id = pa.planned_activity_id
    JOIN employee              e  ON e.employment_id        = pe.employment_id
    JOIN person                p  ON p.person_id            = e.person_id
    WHERE ci.study_year = 2024
      AND e.employment_id = 'E001'      -- välj lärare här
)

SELECT
    course_code                         AS "Course Code",
    instance_id                         AS "Course Instance ID",
    hp                                  AS "HP",
    study_period                        AS "Period",
    teacher_name                        AS "Teacher's Name",

    SUM(hours) FILTER (WHERE activity_name = 'Lecture')   AS "Lecture Hours",
    SUM(hours) FILTER (WHERE activity_name = 'Tutorial')  AS "Tutorial Hours",
    SUM(hours) FILTER (WHERE activity_name = 'Lab')       AS "Lab Hours",
    SUM(hours) FILTER (WHERE activity_name = 'Seminar')   AS "Seminar Hours",
    SUM(hours) FILTER (
        WHERE activity_name IN ('Workshop','Online','Practical','Group Work','Project')
    ) AS "Other Overhead Hours",
    -- den här blir bara NULL om du inte har någon aktivitet som heter 'Admin'
    SUM(hours) FILTER (WHERE activity_name = 'Admin')     AS "Admin",
    SUM(hours) FILTER (WHERE activity_name = 'Exam')      AS "Exam Hours",

    SUM(hours)                                           AS "Total Hours"
FROM base
GROUP BY
    course_code,
    instance_id,
    hp,
    study_period,
    teacher_name
ORDER BY
    study_period,
    course_code,
    instance_id;
