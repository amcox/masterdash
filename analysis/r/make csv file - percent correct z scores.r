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

test.info <- df.se %>% group_by(test_name, subject, grade) %>%
	summarize(overall_mean = mean(percent, na.rm=T), sd = sd(percent))
dsum.percent <- df.se %>% group_by(teacher_number, teacher_name, school, subject, test_name, grade) %>%
	summarize(average = mean(percent, na.rm=T))
dsum.percent$test_name <- factor(dsum.percent$test_name)
dsum.percent$test_name <- reorder(dsum.percent$test_name, new.order=test.order)
dsum.percent <- merge(dsum.percent, test.info)
dsum.percent$z.score <- apply(dsum.percent, 1, function(r){
	(as.numeric(r[['average']]) - as.numeric(r[['overall_mean']]))/as.numeric(r[['sd']])
})
dsum.percent <- dcast(dsum.percent,
											teacher_number + teacher_name + school + subject + grade ~ test_name,
											value.var="z.score"
)
write.csv(dsum.percent, "../output/percent_correct_z_scores.csv", row.names=F, na="")
