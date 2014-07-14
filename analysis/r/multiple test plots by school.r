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
df <- create_student_school_scores_roll_up(con)

for (s in schools){
  df.s <- subset(df, school == s & grade %in% plain.grades)
	p <- multi_test_by_schools_bar_plot(df.s, s)
  save_plot_as_pdf(p, paste0(long_labeller("school", s), " 2013-14 Benchmark Scores, Single Grades"))
	
	df.s <- subset(df, school == s & grade %in% total.grades)
	p <- multi_test_by_schools_bar_plot(df.s, s)
  save_plot_as_pdf(p, paste0(long_labeller("school", s), " 2013-14 Benchmark Scores, Small Schools"))
}