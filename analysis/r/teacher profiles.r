# Generate teacher profile PDFs for each teacher
library(dplyr)
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

# Get scores by class enrollments
df.se <- get_scores_enrollments_data(con)
df.se$achievement_level <- make_adjusted_als(df.se$achievement_level)

# Get scores by school enrollments
df.gsse <- get_school_scores_enrollments_data(con)
df.gsse$achievement_level <- make_adjusted_als(df.gsse$achievement_level)

# Convert LEAP achievement levels to numbers so they can get a z score
al.numbers <- data.frame(achievement_level=c("A", "M", "B", "AB", "U", "B2", "AB2", "F", "PF", "ES", "MS", "WTS"),
												achievement_code=c(1, 0.75, 0.5, 0.25, 0, 1, 0.5, 0.25, 0, 1, 0.5, 1)
)
df.gsse <- merge(df.gsse, al.numbers)

# Get STAR data
# df.star <- load_star_model_data()
df.star <- load_star_raw_data()
df.star <- df.star %>% group_by(StudentId, subject) %>%
  summarize(last.modeled.gap=mean(gap, na.rm=T))
df.e <- get_enrollments_data(con)
df.star.e <- merge(df.star, df.e, by.x="StudentId", by.y="student_number")
df.students <- get_students_data(con)
df.star.s <- merge(df.star, df.students, by.x="StudentId", by.y="student_number")
d.star.means <- df.star.s %>% group_by(subject.x, subject.y, grade) %>%
  summarize(
  	mean=mean(last.modeled.gap, na.rm=T),
  	sd=sd(last.modeled.gap, na.rm=T)
  )

# Get observation data
df.obs <- get_observation_data(con)
df.obs$quarter <- factor(df.obs$quarter)
d.obs.means <- df.obs %>% group_by(small_school, quarter) %>%
  summarize(
		mean=mean(score, na.rm=T),
		sd=sd(score, na.rm=T)	
  )
all.obs.means <- df.obs %>% group_by(quarter) %>%
  summarize(
    mean=mean(score, na.rm=T),
    sd=sd(score, na.rm=T)	
  )
all.obs.means$small_school <- "Network"

# Do the actual plotting for each teacher
teachers <- unique(df.se$teacher_name)
lapply(teachers, plot.teacher.summary, se.data=df.se, gsse.data=df.gsse,
			star.data=df.star.e, highlights=highlights, star.means=d.star.means,
			obs.data=df.obs, obs.means=d.obs.means, all.obs.means=all.obs.means
)