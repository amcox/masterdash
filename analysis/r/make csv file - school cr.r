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
df.sg <- get_school_scores_enrollments_data(con)

dsum.cr <- ddply(df.sg, .(school, grade, subject, test_name), summarize, cr=length(subset(on_level, on_level==T))/length(on_level) )
dsum.cr$test_name <- factor(dsum.cr$test_name)
dsum.cr$test_name <- reorder(dsum.cr$test_name, new.order=test.order)
dsum.cr <- dcast(dsum.cr, school + grade + subject ~ test_name)
write.csv(dsum.cr, "../output/cr_by_school_grade.csv", row.names=F, na="")