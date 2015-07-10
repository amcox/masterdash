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

dsum.cr <- df.se %>% group_by(teacher_number, teacher_name, school, subject, test_name) %>%
	summarize(cr = mean(on_level, na.rm=T))
dsum.cr$test_name <- factor(dsum.cr$test_name)
dsum.cr$test_name <- reorder(dsum.cr$test_name, new.order=test.order)
dsum.cr <- dcast(dsum.cr, teacher_number + teacher_name + school + subject ~ test_name)
write.csv(dsum.cr, "../output/cr.csv", row.names=F, na="")