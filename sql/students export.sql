SELECT
  s.student_number student_number,
	s.lastfirst name,
  s.dob dob,
  s.gender gender,
  s.state_studentnumber,
  se.email
FROM students s
LEFT JOIN u_def_ext_students se ON se.studentsdcid = s.dcid
JOIN schools sc ON sc.school_number = s.schoolid
AND s.grade_level > -3
AND s.schoolid IN (1, 2, 3, 5, 6, 7, 369701,369999)
-- AND se.leap_count_student = 1
-- AND enroll_status = 0