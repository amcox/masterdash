# Creates and saves a csv that has the average percent correct on each test by
# teacher

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

dsum.percent <- ddply(df.se, .(teacher_number, teacher_name, school, subject, test_name, grade),
                      summarize, average=mean(percent)
)
dsum.percent$test_name <- factor(dsum.percent$test_name)
dsum.percent$test_name <- reorder(dsum.percent$test_name, new.order=test.order)
dsum.percent <- dcast(dsum.percent, teacher_number + teacher_name + school + subject + grade ~ test_name)
write.csv(dsum.percent, "../output/average percent correct.csv", row.names=F, na="")
