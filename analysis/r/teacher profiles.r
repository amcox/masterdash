# Generate teacher profile PDFs for each teacher
library(plyr)
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
df.se$achievement_level <- gsub("AB2", "B", df.se$achievement_level)
df.se$achievement_level <- gsub("B2", "A", df.se$achievement_level)
df.se$achievement_level <- gsub("PF", "U", df.se$achievement_level)
df.se$achievement_level <- gsub("F", "U", df.se$achievement_level)
df.se$achievement_level <- gsub("ES", "A", df.se$achievement_level)
df.se$achievement_level <- gsub("MS", "B", df.se$achievement_level)
df.se$achievement_level <- gsub("WTS", "AB", df.se$achievement_level)

# Get scores by school enrollments
df.gsse <- get_school_scores_enrollments_data(con)
df.gsse$achievement_level <- gsub("AB2", "B", df.gsse$achievement_level)
df.gsse$achievement_level <- gsub("B2", "A", df.gsse$achievement_level)
df.gsse$achievement_level <- gsub("PF", "U", df.gsse$achievement_level)
df.gsse$achievement_level <- gsub("F", "U", df.gsse$achievement_level)
df.gsse$achievement_level <- gsub("ES", "A", df.gsse$achievement_level)
df.gsse$achievement_level <- gsub("MS", "B", df.gsse$achievement_level)
df.gsse$achievement_level <- gsub("WTS", "AB", df.gsse$achievement_level)
# Convert LEAP achievement levels to numbers so they can get a z score
al.numbers <- data.frame(achievement_level=c("A", "M", "B", "AB", "U", "B2", "AB2", "F", "PF", "ES", "MS", "WTS"),
												achievement_code=c(1, 0.75, 0.5, 0.25, 0, 1, 0.5, 0.25, 0, 1, 0.5, 1)
)
df.gsse <- merge(df.gsse, al.numbers)

# Make df to highlight benchmark and leap scores
highlights <- data.frame(test=c("MLQ1", "MLQ2", "MLQ3", "MLQ4", "MLQ5", "MLQ6", "MLQ7"),
                        perc=c(1,1,1,1,1,1,1)
)

# Get STAR data
df.star <- read.csv(file="../data/student star summary.csv", head=TRUE, na.string=c("", " ", "  "))
df.e <- get_enrollments_data(con)
df.star.e <- merge(df.star, df.e, by.x="StudentId", by.y="student_number")
df.students <- get_students_data(con)
df.star.s <- merge(df.star, df.students, by.x="StudentId", by.y="student_number")
d.star.means <- ddply(df.star.s, .(subject.x, subject.y, grade.y), summarize,
											mean=mean(last.modeled.gap, na.rm=T),
											sd=sd(last.modeled.gap, na.rm=T)
)

# Get observation data
df.obs <- get_observation_data(con)
df.obs$quarter <- factor(df.obs$quarter)
d.obs.means <- ddply(df.obs, .(small_school, quarter), summarize,
										mean=mean(score, na.rm=T),
										sd=sd(score, na.rm=T)	
)
all.obs.means <- ddply(df.obs, .(quarter), summarize,
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