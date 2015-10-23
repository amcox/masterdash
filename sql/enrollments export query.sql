SELECT
  s.student_number student_number,
	sse.unique_id teacher_number,
	u.email_addr teacher_email,
  c.course_name course_name,
  cc.section_number section,
  sch.abbreviation school,
  cc.dateenrolled entry_date,
  cc.dateleft exit_date,
  CASE ce.instruction_subject
    WHEN 'ELA' THEN 'ela'
    WHEN 'Math' THEN 'math'
    WHEN 'Science' THEN 'sci'
    WHEN 'SS' THEN 'soc'
    ELSE NULL
	END subject,
  sec.room cohort,
  ce.instruction_type class_type,
	'FALSE' fay,
	'TRUE' "current",
	2016 "year"
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
--AND cc.dateleft > CURRENT_DATE
-- WHERE cc.dateenrolled <= TO_DATE('2014-04-07', 'YYYY-MM-DD')
AND cc.dateleft > TO_DATE('2015-10-01', 'YYYY-MM-DD')
AND s.grade_level > -3
AND sch.school_number IN (1,2,3,5,6,7,369701,369999)
AND ce.instruction_type = 'Core'