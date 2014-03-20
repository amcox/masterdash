# Makes two files for each test, facted by grade (or grade category) and
# subject, showing schools as bars.

library(plyr)
library(dplyr)
library(gdata)
library(reshape2)
library(ggplot2)
library(scales)
library(gridExtra)

update_functions <- function() {
	old.wd <- getwd()
	setwd("functions")
	sapply(list.files(), source)
	setwd(old.wd)
}
update_functions()

con <- prepare_connection()

# TODO: Need to repeat the roll-up process below for combined subjects, too

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
# d.percs <- d.percs[order(as.numeric(d.percs$achievement.level)),]


single_test_bar_percs_plot <- function(d, test.name.str) {
  ggplot(d, aes(x=school, y=perc, fill=achievement.level))+
  		geom_bar(stat="identity")+
  		scale_x_discrete(limits=schools)+
  		scale_y_continuous(labels=percent, breaks=seq(0,1,.1))+
  		scale_fill_manual(values=alPalette, guide=F)+
  		ylab("Percent of Scores")+
  		xlab("School")+
  		labs(title=paste0("2013 ", test.name.str, " Scores"))+
  		facet_grid(subject ~ grade, labeller=short_labeller)+
  		theme_bw()+
  		theme(axis.text.x=element_text(size=5, angle=90, vjust=0.5),
  					axis.text.y=element_text(size=6)
  		)
}

for (t in test.order){
  df.t <- subset(d.percs, test_name == t & grade %in% plain.grades)
	p <- single_test_bar_percs_plot(df.t, t)
  save_plot_as_pdf(p, paste0("2013 ", t, " Scores by Grades.pdf"))
	
	df.t <- subset(d.percs, test_name == t & grade %in% total.grades)
	p <- single_test_bar_percs_plot(df.t, t)
  save_plot_as_pdf(p, paste0("2013 ", t, " Scores by Small Schools.pdf"))
}