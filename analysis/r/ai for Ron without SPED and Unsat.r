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

# For Ron, without SPED and Unsat students
df.se <- get_sped_scores_data(con)
df.se <- subset(df.se, sped_category == 'gened')
df.se$grade.category <- cut_grade_categories(df.se$grade)

d.l13 <- subset(df.se, test_name == 'L13')
d.l13 <- subset(d.l13, achievement_level != 'U')
d.l14 <- subset(df.se, test_name == 'L14')
d.both <- merge(d.l13, d.l14, by=c("student_number", "subject"))
d.both$id.sub <- apply(d.both, 1, function(r) {
  paste0(r['student_number'], r['subject'])
})
allowed.student.subs <- unique(d.both$id.sub)

df.se$student.sub <- apply(df.se, 1, function(r) {
  paste0(r['student_number'], r['subject'])
})
df.se <- subset(df.se, student.sub %in% allowed.student.subs)

dsum.ai <- ddply(df.se, .(school, grade, subject, test_name), summarize, ai=mean(ai_points))
ai.gc <- ddply(df.se, .(school, grade.category, subject, test_name), summarize, ai=mean(ai_points))
names(ai.gc)[names(ai.gc) == 'grade.category'] <- 'grade'
dsum.ai <- rbind(dsum.ai, ai.gc)
dsum.ai$test_name <- factor(dsum.ai$test_name)
dsum.ai$test_name <- reorder(dsum.ai$test_name, new.order=test.order)
dsum.ai <- dcast(dsum.ai, school + subject + grade ~ test_name)
save_df_as_csv(dsum.ai, "ai by school, just GenEd, no Unsat")