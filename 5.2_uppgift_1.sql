WITH base AS (
    SELECT
        cl.course_code,
        ci.instance_id,
        cl.hp,
        ci.study_period,
        ci.num_students,
        ta.activity_name,
        (pa.planned_hours * COALESCE(ta.factor, 1)) AS hours
    FROM course_instance      ci
    JOIN course_layout        cl ON ci.course_layout_id = cl.course_layout_id
    JOIN planned_activity     pa ON pa.instance_id      = ci.instance_id
    JOIN teaching_activity    ta ON ta.teaching_activity_id = pa.teaching_activity_id
    WHERE ci.study_year = 2024
)

SELECT
    b.course_code                        AS "Course Code",
    b.instance_id                        AS "Course Instance ID",
    b.hp                                 AS "HP",
    b.study_period                       AS "Period",
    b.num_students                       AS "# Students",

    SUM(hours) FILTER (WHERE activity_name = 'Lecture')  AS "Lecture Hours",
    SUM(hours) FILTER (WHERE activity_name = 'Tutorial') AS "Tutorial Hours",
    SUM(hours) FILTER (WHERE activity_name = 'Lab')      AS "Lab Hours",
    SUM(hours) FILTER (WHERE activity_name = 'Seminar')  AS "Seminar Hours",

    SUM(hours) FILTER (
        WHERE activity_name IN ('Workshop','Online','Practical','Group Work','Project')
    ) AS "Other Overhead Hours",

    SUM(hours) FILTER (WHERE activity_name = 'Exam')     AS "Exam Hours",

    SUM(hours)                                           AS "Total Hours"

FROM base b
GROUP BY
    b.course_code,
    b.instance_id,
    b.hp,
    b.study_period,
    b.num_students
ORDER BY
    b.course_code,
    b.instance_id;


