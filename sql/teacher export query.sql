SELECT DISTINCT
  u.lastfirst teacher_name,
  sse.unique_id teacher_number
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
AND s.grade_level > -1
AND sch.school_number IN (1,2,3,6)
AND ce.instruction_type = 'Core'