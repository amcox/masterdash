SELECT
	s.student_number student_number,
	TO_CHAR(e.entrydate, 'YYYY-MM-DD') entry_date,
	TO_CHAR(e.exitdate, 'YYYY-MM-DD') exit_date,
	sc.abbreviation school_abb,
	e.grade_level grade,
	ps_customfields.getStudentscf(s.id, 'la_sped') la_sped,
	se.laa1 laa1,
	t.name year
FROM PSSIS_Enrollment_All e
LEFT JOIN students s ON e.studentid = s.id
LEFT JOIN schools sc ON e.schoolid = sc.school_number
LEFT JOIN u_def_ext_students se ON se.studentsdcid = s.dcid
LEFT JOIN terms t ON t.yearid = e.yearid AND t.portion = 1 AND t.schoolid = e.schoolid
WHERE t.id LIKE '25%'
AND e.grade_level < 99
AND e.grade_level > -3
AND e.schoolid IN (1, 2, 3, 5, 6, 7, 369701, 369999)
