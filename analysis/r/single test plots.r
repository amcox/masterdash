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

single_test_bar_percs_plot <- function(d, test.name.str) {
  ggplot(d, aes(x=school, y=perc, fill=achievement.level))+
  		geom_bar(stat="identity")+
  		scale_x_discrete(limits=schools)+
  		scale_y_continuous(labels=percent, breaks=seq(0,1,.1))+
  		scale_fill_manual(values=alPalette, guide=F)+
  		ylab("Percent of Scores")+
  		xlab("School")+
  		labs(title=paste0("2013 ", test.name.str, " Scores"))+
  		facet_grid(subject ~ grade, labeller=short_labeller)+
  		theme_bw()+
  		theme(axis.text.x=element_text(size=5, angle=90, vjust=0.5),
  					axis.text.y=element_text(size=6)
  		)
}

con <- prepare_connection()
df <- create_student_school_scores_roll_up(con)

for (t in test.order){
  df.t <- subset(df, test_name == t & grade %in% plain.grades)
	p <- single_test_bar_percs_plot(df.t, t)
  save_plot_as_pdf(p, paste0("2013-14 ", t, " Scores by Grades"))
	
	df.t <- subset(df, test_name == t & grade %in% total.grades)
	p <- single_test_bar_percs_plot(df.t, t)
  save_plot_as_pdf(p, paste0("2013-14 ", t, " Scores by Small Schools"))
}