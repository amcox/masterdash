create_student_school_scores_roll_up_ai <- function(con, y=2016) {
  # Get scores
  df <- get_single_score_per_student_with_student_data(con)
	df <- df %>% subset(ending_year == y)
  df$grade.category <- cut_grade_categories(df$grade)
  df$small.school <- make_small_school_labels(df)
  df <- subset(df, !achievement_level %in% c("WTS", "MS", "ES"))

  # Make percents by achievement level
		d.percs <- df %>% group_by(school, grade, subject, test_name) %>%
			 summarize(ai = mean(ai_points, na.rm=T))
    # and all schools
			dt <- df %>% group_by(grade, subject, test_name) %>%
        summarize(ai = mean(ai_points, na.rm=T))
      dt$school <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
    # and all subjects
			dt <- df %>% group_by(school, grade, test_name) %>%
         summarize(ai = mean(ai_points, na.rm=T))
      dt$subject <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
      # and all schools and subjects
				dt <- df %>% group_by(grade, test_name) %>%
           summarize(ai = mean(ai_points, na.rm=T))
        dt$school <- rep("all", nrow(dt))
        dt$subject <- rep("all", nrow(dt))
        d.percs <- rbind(d.percs, dt)

  # Small school totals, added to the grade totals
		dt <- df %>% group_by(school, grade.category, subject, test_name) %>%
         summarize(ai = mean(ai_points, na.rm=T))
    names(dt) <- gsub("grade.category", "grade", names(dt))
    d.percs <- rbind(d.percs, dt)
    # and all schools
			dt <- df %>% group_by(grade.category, subject, test_name) %>%
          summarize(ai = mean(ai_points, na.rm=T))
      names(dt) <- gsub("grade.category", "grade", names(dt))
      dt$school <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
    # and all subjects
			dt <- df %>% group_by(school, grade.category, test_name) %>%
          summarize(ai = mean(ai_points, na.rm=T))
      names(dt) <- gsub("grade.category", "grade", names(dt))
      dt$subject <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
      # and all school totals and subjects
				dt <- df %>% group_by(grade.category, test_name) %>%
          summarize(ai = mean(ai_points, na.rm=T))
        names(dt) <- gsub("grade.category", "grade", names(dt))
        dt$subject <- rep("all", nrow(dt))
        dt$school <- rep("all", nrow(dt))
        d.percs <- rbind(d.percs, dt)

  # 3-8, added to the grade totals
    ds <- subset(df, grade > 2)
		dt <- ds %>% group_by(school, subject, test_name) %>%
        summarize(ai = mean(ai_points, na.rm=T))
    dt$grade <- rep("3_8", nrow(dt))
    d.percs <- rbind(d.percs, dt)
    # and all schools
			dt <- ds %>% group_by(subject, test_name) %>%
				    summarize(ai = mean(ai_points, na.rm=T))
      dt$grade <- rep("3_8", nrow(dt))
      dt$school <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
    # and all subjects
			dt <- ds %>% group_by(school, test_name) %>%
				      summarize(ai = mean(ai_points, na.rm=T))
      dt$grade <- rep("3_8", nrow(dt))
      dt$subject <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
      # and all schools and subjects
				dt <- ds %>% group_by(test_name) %>%
					     summarize(ai = mean(ai_points, na.rm=T))
        dt$grade <- rep("3_8", nrow(dt))
        dt$school <- rep("all", nrow(dt))
        dt$subject <- rep("all", nrow(dt))
        d.percs <- rbind(d.percs, dt)

  # K-8, added to the grade totals
	dt <- df %>% group_by(school, subject, test_name) %>%
		        summarize(ai = mean(ai_points, na.rm=T))
  dt$grade <- rep("PK_8", nrow(dt))
  d.percs <- rbind(d.percs, dt)
    # and all schools
			dt <- df %>% group_by(subject, test_name) %>%
				      summarize(ai = mean(ai_points, na.rm=T))
      dt$grade <- rep("PK_8", nrow(dt))
      dt$school <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
    # and all subjects
			dt <- df %>% group_by(school, test_name) %>%
				      summarize(ai = mean(ai_points, na.rm=T))
      dt$grade <- rep("PK_8", nrow(dt))
      dt$subject <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
      # and all schools and subjects
				dt <- df %>% group_by(test_name) %>%
					summarize(ai = mean(ai_points, na.rm=T))
        dt$grade <- rep("PK_8", nrow(dt))
        dt$school <- rep("all", nrow(dt))
        dt$subject <- rep("all", nrow(dt))
        d.percs <- rbind(d.percs, dt)

  # Factorize and order
  d.percs <- turn_chars_to_factors(d.percs)
  #d.percs$achievement.level <- reorder(d.percs$achievement.level, 
#  																	new.order=c("A", "M", "B", "AB", "U")
 # )
#  d.percs <- d.percs[order(as.numeric(d.percs$achievement.level)),]
  d.percs$subject <- reorder(d.percs$subject, new.order=subjects.order)
  d.percs$grade <- reorder(d.percs$grade, new.order=all.grades)

  return(d.percs)
}