library(RPostgreSQL)

prepare_connection <- function(){
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv, dbname="masterdash_development", host="localhost", port=5432)
  return(con)
}

check_for_con_and_create <- function(con_to_test=NA){
  if(is.na(con_to_test)){
    con <- prepare_connection()
  }
  return(con)
}

con <- check_for_con_and_create(con)

get_scores_enrollments_data <- function(con=NA){
  scores.enrollments.query <- "SELECT s.*,
  		e.subject subject,
  		e.grade grade,
  		e.school school,
  		e.section section,
  		t.teacher_number teacher_number,
  		t.name teacher_name,
  		tests.name test_name,
  		tests.order test_order
  FROM enrollments e
  JOIN scores s ON s.student_id = e.student_id AND e.subject = s.subject
  JOIN teachers t ON t.id = e.teacher_id
  JOIN tests ON tests.id = s.test_id"

  return(dbGetQuery(con, scores.enrollments.query))
}

get_school_scores_enrollments_data <- function(con=NA) {
  # This returns one score per student-school-subject-test
  # with section information
  scores.enrollments.query <- "SELECT s.*,
  		e.grade grade,
  		e.school school,
  		e.section section,
  		t.teacher_number teacher_number,
  		t.name teacher_name,
  		tests.name test_name,
  		tests.order test_order
  FROM (
  	SELECT student_id,
  		subject,
  		school,
  		teacher_id,
  		MAX(grade) grade,
  		year,
  		MAX(section) section,
  		class_type
  	FROM enrollments
  	GROUP BY student_id, subject, school, teacher_id, year, class_type
  ) e
  JOIN scores s ON s.student_id = e.student_id AND e.subject = s.subject
  JOIN teachers t ON t.id = e.teacher_id
  JOIN tests ON tests.id = s.test_id"
  
  return(dbGetQuery(con, scores.enrollments.query))
}

get_single_score_per_student_with_student_data <- function(con=NA) {
  # This returns one score per student-school-subject-test
  # without section information, with student ID
  q <- "SELECT s.*,
  		e.grade grade,
  		e.school school,
  		tests.name test_name,
  		tests.order test_order,
      st.student_number student_number
  FROM (
  	SELECT student_id,
  		subject,
  		school,
  		MAX(grade) grade,
  		year
  	FROM enrollments
    WHERE class_type = 'Core'
  	GROUP BY student_id, subject, school, year
  ) e
  JOIN scores s ON s.student_id = e.student_id AND e.subject = s.subject
  JOIN tests ON tests.id = s.test_id
  JOIN students st ON st.id = s.student_id"
  
  return(dbGetQuery(con, q))
}

get_enrollments_data <- function(con=NA){
  enrollments.query <- "SELECT
  		s.student_number,
  		e.subject subject,
  		e.grade grade,
  		e.school school,
  		e.section section,
  		t.teacher_number teacher_number,
  		t.name teacher_name
  FROM enrollments e
  JOIN teachers t ON t.id = e.teacher_id
  JOIN students s ON s.id = e.student_id"
  
  return(dbGetQuery(con, enrollments.query))
}

get_students_data <- function(con) {
  students.query <- "SELECT DISTINCT
  		s.student_number,
  		e.subject subject,
  		e.grade grade
  FROM enrollments e
  JOIN students s ON s.id = e.student_id"
  
  return(dbGetQuery(con, students.query))
}

get_observation_data <- function(con) {
  obs.query <- "SELECT
  		o.*,
  		t.*
  FROM observations o
  JOIN teachers t ON t.id = o.teacher_id"
  return(dbGetQuery(con, obs.query))
}

get_sped_scores_data <- function(con) {
  sped.scores.query <- "SELECT *,
  		CASE achievement_level
  			WHEN 'B2' THEN 'M'
  			WHEN 'AB2' THEN 'B'
  			WHEN 'F' THEN 'AB'
  			WHEN 'PF' THEN 'U'
  			ELSE achievement_level
  		END adj_achievement_level,
  		CASE
  			WHEN state_test = 'LAA' THEN 'laa'
  			WHEN iep_speech_only THEN 'speech_only'
  			WHEN la_sped = 1 THEN 'iep_no_speech'
  			ELSE 'gened'
  		END sped_category
  FROM (
  	SELECT s.*,
  			st.la_sped,
  			st.iep_speech_only,
  			st.student_number,
  			CASE e.subject
  	    WHEN 'ela' THEN
  				st.state_test_ela
  	    WHEN 'math' THEN
  				st.state_test_math
  	    WHEN 'sci' THEN
  				st.state_test_sci
  	    WHEN 'soc' THEN
  				st.state_test_soc
  	    ELSE NULL
  		END state_test,
  			e.subject subject,
  			e.grade grade,
  			e.school school,
  			tests.name test_name,
  			tests.order test_order
  	FROM (
  		SELECT student_id,
  			subject,
  			school,
  			MAX(grade) grade,
  			year,
  			class_type
  		FROM enrollments
  		GROUP BY student_id, subject, school, year, class_type
  	) e
  	JOIN scores s ON s.student_id = e.student_id AND e.subject = s.subject
  	JOIN tests ON tests.id = s.test_id
  	JOIN students st ON s.student_id = st.id
  ) scores_info
  WHERE achievement_level NOT IN ('WTS', 'MS', 'ES')"
  d <- data.frame(dbGetQuery(con, sped.scores.query), stringsAsFactors=T)
  d <- data.frame(rapply(d, as.factor, classes="character",
  											how="replace")
  )
  return(d)
}