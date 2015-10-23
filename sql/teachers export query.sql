SELECT DISTINCT
  u.lastfirst teacher_name,
  sse.unique_id renew_ID,
  u.email_addr,
  u.teachernumber PS_ID
FROM cc
JOIN students s ON cc.studentID = s.id
LEFT JOIN schoolstaff ss ON ss.id = cc.teacherid
LEFT JOIN users u ON u.dcid = ss.users_dcid
LEFT JOIN u_def_ext_schoolstaff sse ON sse.schoolstaffdcid = ss.dcid
JOIN courses c ON cc.course_number = c.course_number
LEFT JOIN u_def_ext_courses ce ON ce.coursesdcid = c.dcid
JOIN schools sch ON cc.schoolid = sch.school_number
WHERE cc.dateenrolled <= CURRENT_DATE
AND cc.dateleft > CURRENT_DATE
AND s.grade_level > -3
AND sch.school_number IN (1,2,3,5,6,7,369701,369999)
AND ce.instruction_type = 'Core'