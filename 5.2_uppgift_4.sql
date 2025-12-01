WITH teacher_courses AS (
    SELECT
        e.employment_id,
        CONCAT(p.first_name, ' ', p.last_name) AS teacher_name,
        ci.study_period,
        ci.study_year,
        ci.instance_id
    FROM planned_employee      pe
    JOIN employee              e  ON e.employment_id        = pe.employment_id
    JOIN person                p  ON p.person_id            = e.person_id
    JOIN planned_activity      pa ON pa.planned_activity_id = pe.planned_activity_id
    JOIN course_instance       ci ON ci.instance_id         = pa.instance_id
    WHERE ci.study_year  = 2024      -- aktuellt år
      AND ci.study_period = 'P1'     -- "current period" = P1
)

SELECT
    employment_id                        AS "Employment ID",
    teacher_name                         AS "Teacher's Name",
    study_period                         AS "Period",
    COUNT(DISTINCT instance_id)          AS "No of courses"
FROM teacher_courses
GROUP BY
    employment_id,
    teacher_name,
    study_period
HAVING
    COUNT(DISTINCT instance_id) > 1      -- specificerat gränsvärde (t.ex. mer än 1 kurs)
ORDER BY
    teacher_name;