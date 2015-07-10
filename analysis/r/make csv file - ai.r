# Creates and saves a csv that has the percent correct z score for each teacher
library(dplyr)
library(gdata)
library(reshape2)

update_functions <- function() {
	old.wd <- getwd()
	setwd("functions")
	sapply(list.files(), source)
	setwd(old.wd)
}
update_functions()

con <- prepare_connection()
df.se <- get_scores_enrollments_data(con)

# By teacher
dsum.ai <- df.se %>%
	group_by(teacher_number, teacher_name, school, subject, test_name, grade) %>%
	summarize(ai = mean(ai_points, na.rm=T))
dsum.ai$test_name <- factor(dsum.ai$test_name)
dsum.ai$test_name <- reorder(dsum.ai$test_name, new.order=test.order)
dsum.ai <- dcast(dsum.ai, teacher_number + teacher_name + school + subject + grade ~ test_name)
write.csv(dsum.ai, "../output/ai.csv", row.names=F, na="")


# By school
df.se <- get_school_scores_enrollments_data(con)
dsum.ai <- df.se %>%
	group_by(school, grade, subject, test_name) %>%
	summarize(ai = mean(ai_points, na.rm=T))
dsum.ai$test_name <- factor(dsum.ai$test_name)
dsum.ai$test_name <- reorder(dsum.ai$test_name, new.order=test.order)
dsum.ai <- dcast(dsum.ai, school + subject + grade ~ test_name)
save_df_as_csv(dsum.ai, "ai by school")
