create_student_school_scores_roll_up <- function(con) {
  # Get scores
  df <- get_single_score_per_student_data(con)
  df$grade.category <- cut_grade_categories(df$grade)
  df$small.school <- make_small_school_labels(df)
  df <- subset(df, !achievement_level %in% c("WTS", "MS", "ES"))
  df$adj_achievement_level <- make_adjusted_als(df$achievement_level)

  # Make percents by achievement level
    d.percs <- ddply(df, .(school, grade, subject, test_name),
                function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
    )
    # and all schools
      dt <- ddply(df, .(grade, subject, test_name),
                  function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
      )
      dt$school <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
    # and all subjects
      dt <- ddply(df, .(school, grade, test_name),
                  function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
      )
      dt$subject <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
      # and all schools and subjects
        dt <- ddply(df, .(grade, test_name),
                    function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
        )
        dt$school <- rep("all", nrow(dt))
        dt$subject <- rep("all", nrow(dt))
        d.percs <- rbind(d.percs, dt)

  # Small school totals, added to the grade totals
    dt <- ddply(df, .(school, grade.category, subject, test_name),
                function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
    )
    names(dt) <- gsub("grade.category", "grade", names(dt))
    d.percs <- rbind(d.percs, dt)
    # and all schools
      dt <- ddply(df, .(grade.category, subject, test_name),
                  function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
      )
      names(dt) <- gsub("grade.category", "grade", names(dt))
      dt$school <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
    # and all subjects
      dt <- ddply(df, .(school, grade.category, test_name),
                  function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
      )
      names(dt) <- gsub("grade.category", "grade", names(dt))
      dt$subject <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
      # and all school totals and subjects
        dt <- ddply(df, .(grade.category, test_name),
                    function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
        )
        names(dt) <- gsub("grade.category", "grade", names(dt))
        dt$subject <- rep("all", nrow(dt))
        dt$school <- rep("all", nrow(dt))
        d.percs <- rbind(d.percs, dt)

  # 3-8, added to the grade totals
    ds <- subset(df, grade > 2)
    dt <- ddply(ds, .(school, subject, test_name),
                function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
    )
    dt$grade <- rep("3-8", nrow(dt))
    d.percs <- rbind(d.percs, dt)
    # and all schools
      dt <- ddply(ds, .(subject, test_name),
                  function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
      )
      dt$grade <- rep("3-8", nrow(dt))
      dt$school <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
    # and all subjects
      dt <- ddply(ds, .(school, test_name),
                  function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
      )
      dt$grade <- rep("3-8", nrow(dt))
      dt$subject <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
      # and all schools and subjects
        dt <- ddply(ds, .(test_name),
                    function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
        )
        dt$grade <- rep("3-8", nrow(dt))
        dt$school <- rep("all", nrow(dt))
        dt$subject <- rep("all", nrow(dt))
        d.percs <- rbind(d.percs, dt)

  # K-8, added to the grade totals
  dt <- ddply(df, .(school, subject, test_name),
              function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
  )
  dt$grade <- rep("0-8", nrow(dt))
  d.percs <- rbind(d.percs, dt)
    # and all schools
      dt <- ddply(df, .(subject, test_name),
                  function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
      )
      dt$grade <- rep("0-8", nrow(dt))
      dt$school <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
    # and all subjects
      dt <- ddply(df, .(school, test_name),
                  function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
      )
      dt$grade <- rep("0-8", nrow(dt))
      dt$subject <- rep("all", nrow(dt))
      d.percs <- rbind(d.percs, dt)
      # and all schools and subjects
        dt <- ddply(df, .(test_name),
                    function(d) {percents_of_total_als(d$adj_achievement_level, 'achievement.level')}							
        )
        dt$grade <- rep("0-8", nrow(dt))
        dt$school <- rep("all", nrow(dt))
        dt$subject <- rep("all", nrow(dt))
        d.percs <- rbind(d.percs, dt)

  # Factorize and order
  d.percs <- turn_chars_to_factors(d.percs)
  d.percs$achievement.level <- reorder(d.percs$achievement.level, 
  																	new.order=c("A", "M", "B", "AB", "U")
  )
  d.percs <- d.percs[order(as.numeric(d.percs$achievement.level)),]
  d.percs$subject <- reorder(d.percs$subject, new.order=subjects.order)
  d.percs$grade <- reorder(d.percs$grade, new.order=all.grades)

  return(d.percs)
}