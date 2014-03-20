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

multi_test_by_schools_bar_plot <- function(d, s) {
  ggplot(d, aes(x=test_name, y=perc, fill=achievement.level))+
  		geom_bar(stat="identity")+
  		scale_x_discrete(limits=test.order)+
  		scale_y_continuous(labels=percent, breaks=seq(0,1,.1))+
  		scale_fill_manual(values=alPalette, guide=F)+
  		ylab("Percent of Scores")+
  		xlab("Assessment")+
  		labs(title=paste0(long_labeller("school", s), " 2013-14 Benchmark Scores by Subject and Grade"))+
  		facet_grid(subject ~ grade, labeller=short_labeller)+
  		theme_bw()+
  		theme(axis.text.x=element_text(size=5, angle=90, vjust=0.5),
  					axis.text.y=element_text(size=6)
  		)
}

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