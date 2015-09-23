# Makes two files for each test, facted by grade (or grade category) and
# subject, showing schools as bars.

library(dplyr)
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

multi_test_by_subjects_bar_plot_ai <- function(d, s) {
  ggplot()+
		geom_bar(data=d, aes(x=test_name, y=ai), fill="purple", stat="identity")+
    geom_text(data=d, aes(label=round(ai, digits=0), x=test_name, y=ai + 3), size=2)+
		scale_x_discrete(limits=test.order)+
		scale_y_continuous(breaks=seq(0,150,20), limits=c(0,150))+
#		scale_fill_manual(values=alPalette.light.lows, guide=F)+
		labs(title=paste0(long_labeller("subject", s), " 2015-16 Benchmark Scores by Subject and Grade AI"),
      x='Assessment',
      y='Assessment Index'
    )+
		facet_grid(school ~ grade, labeller=short_labeller)+
		theme_bw()+
		theme(axis.text.x=element_text(size=5, angle=90, vjust=0.5),
					axis.text.y=element_text(size=6)
		)
}

con <- prepare_connection()
df <- create_student_school_scores_roll_up_ai(con)

df <- subset(df, school != "RSP")
df$school <- reorder(df$school, new.order=schools)

for (s in subjects.order){
  df.s <- subset(df, subject == s & grade %in% plain.grades.nok2)
 # d.cr <- df.s %>% group_by(school, grade, subject, test_name) %>% do(b_and_above(.))
	p <- multi_test_by_subjects_bar_plot_ai(df.s, s)
  save_plot_as_pdf(p, paste0(long_labeller("subject", s), " 2015-16 Benchmark Scores AI, 3-8 Single Grades"))
	
	df.s <- subset(df, subject == s & grade %in% total.grades.nok2)
# d.cr <- df.s %>% group_by(school, grade, subject, test_name) %>% do(b_and_above(.))
	p <- multi_test_by_subjects_bar_plot_ai(df.s, s)
  save_plot_as_pdf(p, paste0(long_labeller("subject", s), " 2015-16 Benchmark Scores AI, 3-8 Small Schools"))
  
	if(s != 'soc'){
    df.s <- subset(df, subject == s & grade %in% k2.grades)
   # d.cr <- df.s %>% group_by(school, grade, subject, test_name) %>% do(m_and_above(.))
  	p <- multi_test_by_subjects_bar_plot(df.s, s) + scale_fill_manual(values=alPalette.light.lows.k2, guide=F)
    save_plot_as_pdf(p, paste0(long_labeller("subject", s), " 2015-16 Benchmark Scores AI, PK-2"))
	}
}