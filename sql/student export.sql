SELECT
  s.student_number student_number,
	s.lastfirst name,
  sc.abbreviation current_school,
	ps_customfields.getStudentscf(s.id, 'la_sped') la_sped,
  se.iep_speech_only iep_speech_only,
	CASE WHEN se.state_test_ela LIKE '%LAA%' THEN 'LAA' ELSE NULL END state_test_ela,
	CASE WHEN se.state_test_math LIKE '%LAA%' THEN 'LAA' ELSE NULL END state_test_math,
	CASE WHEN se.state_test_science LIKE '%LAA%' THEN 'LAA' ELSE NULL END state_test_sci,
	CASE WHEN se.state_test_ss LIKE '%LAA%' THEN 'LAA' ELSE NULL END state_test_soc,
	s.grade_level state_grade
FROM students s
LEFT JOIN u_def_ext_students se ON se.studentsdcid = s.dcid
JOIN schools sc ON sc.school_number = s.schoolid
AND s.grade_level > -3
AND s.schoolid IN (1, 2, 3, 6, 7, 369701)
-- AND se.leap_count_student = 1
-- AND enroll_status = 0