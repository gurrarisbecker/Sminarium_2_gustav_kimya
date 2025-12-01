WITH base AS (
    SELECT
        cl.course_code,
        ci.instance_id,
        e.employment_id,
        CONCAT(p.first_name, ' ', p.last_name) AS teacher_name,
        ci.study_period,
        ci.study_year,
        ta.activity_name,
        (pa.planned_hours * COALESCE(ta.factor, 1)) AS hours
    FROM planned_employee      pe
    JOIN employee              e  ON e.employment_id        = pe.employment_id
    JOIN person                p  ON p.person_id            = e.person_id
    JOIN planned_activity      pa ON pa.planned_activity_id = pe.planned_activity_id
    JOIN teaching_activity     ta ON ta.teaching_activity_id = pa.teaching_activity_id
    JOIN course_instance       ci ON ci.instance_id         = pa.instance_id
    JOIN course_layout         cl ON cl.course_layout_id    = ci.course_layout_id
    WHERE ci.study_year = 2024
)

SELECT
    course_code                         AS "Course Code",
    instance_id                         AS "Course Instance ID",
    employment_id                       AS "Employment ID",
    teacher_name                        AS "Teacher",
    study_period                        AS "Period",

    SUM(hours) FILTER (WHERE activity_name = 'Lecture')  AS "Lecture Hours",
    SUM(hours) FILTER (WHERE activity_name = 'Lab')      AS "Lab Hours",
    SUM(hours) FILTER (WHERE activity_name = 'Seminar')  AS "Seminar Hours",
    SUM(hours) FILTER (WHERE activity_name = 'Tutorial') AS "Tutorial Hours",
    SUM(hours) FILTER (
        WHERE activity_name IN ('Workshop','Online','Practical','Group Work','Project')
    ) AS "Other Overhead Hours",
    SUM(hours) FILTER (WHERE activity_name = 'Exam')     AS "Exam Hours",
    SUM(hours)                                           AS "Total Hours"

FROM base
WHERE study_period = 'P1'
GROUP BY
    course_code,
    instance_id,
    employment_id,
    teacher_name,
    study_period
ORDER BY
    course_code,
    instance_id,
    teacher_name;
