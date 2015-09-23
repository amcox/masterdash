SELECT
  s.student_number student_number,
	sse.unique_id teacher_number,
  c.course_name course_name,
  cc.section_number section,
  CASE ce.instruction_subject
    WHEN 'ELA' THEN
			CASE
			WHEN se.benchmark_grade_level_ela IS NOT NULL
			THEN CAST(se.benchmark_grade_level_ela AS VARCHAR2(10))
			ELSE CAST(s.grade_level AS VARCHAR2(10))
			END
    WHEN 'Math' THEN
			CASE
			WHEN se.benchmark_grade_level_math IS NOT NULL
			THEN CAST(se.benchmark_grade_level_math AS VARCHAR2(10))
			ELSE CAST(s.grade_level AS VARCHAR2(10))
			END
    WHEN 'Science' THEN
			CASE
			WHEN se.benchmark_grade_level_sci IS NOT NULL
			THEN CAST(se.benchmark_grade_level_sci AS VARCHAR2(10))
			ELSE CAST(s.grade_level AS VARCHAR2(10))
			END
    WHEN 'SS' THEN
			CASE
			WHEN se.benchmark_grade_level_ss IS NOT NULL
			THEN CAST(se.benchmark_grade_level_ss AS VARCHAR2(10))
			ELSE CAST(s.grade_level AS VARCHAR2(10))
			END
    ELSE NULL
	END grade,
  sch.abbreviation school,
  CASE ce.instruction_subject
    WHEN 'ELA' THEN 'ela'
    WHEN 'Math' THEN 'math'
    WHEN 'Science' THEN 'sci'
    WHEN 'SS' THEN 'soc'
    ELSE NULL
	END subject,
  ce.instruction_type class_type,
	'FALSE' fay,
	'TRUE' "current",
	2015 "year"
FROM cc
JOIN students s ON cc.studentID = s.id
LEFT JOIN u_def_ext_students se ON se.studentsdcid = s.dcid
LEFT JOIN schoolstaff ss ON ss.id = cc.teacherid
LEFT JOIN users u ON u.dcid = ss.users_dcid
LEFT JOIN u_def_ext_schoolstaff sse ON sse.schoolstaffdcid = ss.dcid
JOIN courses c ON cc.course_number = c.course_number
LEFT JOIN u_def_ext_courses ce ON ce.coursesdcid = c.dcid
JOIN schools sch ON cc.schoolid = sch.school_number
JOIN sections sec ON sec.id = cc.sectionid
WHERE cc.dateenrolled <= CURRENT_DATE
AND cc.dateleft > CURRENT_DATE
-- WHERE cc.dateenrolled <= TO_DATE('2014-04-07', 'YYYY-MM-DD')
-- AND cc.dateleft > TO_DATE('2014-04-07', 'YYYY-MM-DD')
AND s.grade_level > -3
AND sch.school_number IN (1,2,3,6,7,369701)
AND ce.instruction_type = 'Core'