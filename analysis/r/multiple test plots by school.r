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
  ggplot()+
		geom_bar(data=d, aes(x=test_name, y=perc, fill=achievement.level), stat="identity")+
    geom_text(data=d.cr, aes(label=round(perc.cr * 100, digits=0), x=test_name, y=perc.cr + .03), size=2)+
		scale_x_discrete(limits=test.order)+
		scale_y_continuous(labels=percent, breaks=seq(0,1,.1), limits=c(0,1.05))+
		scale_fill_manual(values=alPalette.light.lows, guide=F)+
		labs(title=paste0(long_labeller("school", s), " 2014-15 Benchmark Scores by Subject and Grade"),
      x='Assessment',
      y='Percent of Scores'
    )+
		facet_grid(subject ~ grade, labeller=short_labeller)+
		theme_bw()+
		theme(axis.text.x=element_text(size=5, angle=90, vjust=0.5),
					axis.text.y=element_text(size=6)
		)
}

con <- prepare_connection()
df <- create_student_school_scores_roll_up(con)

for (s in schools){
  df.s <- subset(df, school == s & grade %in% plain.grades.nok2 & achievement.level != 'U')
  d.cr <- df.s %>% group_by(school, grade, subject, test_name) %>% do(b_and_above(.))
	p <- multi_test_by_schools_bar_plot(df.s, s)
  save_plot_as_pdf(p, paste0(long_labeller("school", s), " 2014-15 Benchmark Scores, 3-8 Single Grades"))
	
	df.s <- subset(df, school == s & grade %in% total.grades.nok2 & achievement.level != 'U')
  d.cr <- df.s %>% group_by(school, grade, subject, test_name) %>% do(b_and_above(.))
	p <- multi_test_by_schools_bar_plot(df.s, s)
  save_plot_as_pdf(p, paste0(long_labeller("school", s), " 2014-15 Benchmark Scores, 3-8 Small Schools"))
  
	df.s <- subset(df, school == s & grade %in% k2.grades & achievement.level != 'U')
  d.cr <- df.s %>% group_by(school, grade, subject, test_name) %>% do(m_and_above(.))
	p <- multi_test_by_schools_bar_plot(df.s, s) + scale_fill_manual(values=alPalette.light.lows.k2, guide=F)
  save_plot_as_pdf(p, paste0(long_labeller("school", s), " 2014-15 Benchmark Scores, PK-2"))
}