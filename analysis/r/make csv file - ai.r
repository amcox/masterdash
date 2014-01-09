# Creates and saves a csv that has the percent correct z score for each teacher

library(plyr)
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

dsum.ai <- ddply(df.se, .(teacher_number, teacher_name, school, subject, test_name, grade), summarize, ai=mean(ai_points))
dsum.ai$test_name <- factor(dsum.ai$test_name)
dsum.ai$test_name <- reorder(dsum.ai$test_name, new.order=test.order)
dsum.ai <- dcast(dsum.ai, teacher_number + teacher_name + school + subject + grade ~ test_name)
write.csv(dsum.ai, "../output/ai.csv", row.names=F, na="")