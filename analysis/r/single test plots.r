# Makes two files for each test, faceted by grade (or grade category) and
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

single_test_bar_percs_plot <- function(d, d.cr, test.name.str) {
  ggplot()+
  		geom_bar(data=d, aes(x=school, y=perc, fill=achievement.level), stat="identity")+
      geom_text(data=d.cr, aes(label=round(perc.cr * 100, digits=0), x=school, y=(perc.cr + 0.03)), size=2)+
  		scale_x_discrete(limits=schools)+
  		scale_y_continuous(labels=percent, breaks=seq(0,1,.1), limits=c(0,1.05))+
  		scale_fill_manual(values=alPalette.light.lows, guide=F)+
  		labs(title=paste0("2014 ", test.name.str, " Scores"),
        x='School',
        y='Percent of Scores'
      )+
  		facet_grid(subject ~ grade, labeller=short_labeller)+
  		theme_bw()+
  		theme(axis.text.x=element_text(size=9, angle=90, vjust=0.5),
  					axis.text.y=element_text(size=7)
  		)
}

con <- prepare_connection(aws=T)
df <- create_student_school_scores_roll_up(con)

for (t in test.order){
  df.t <- subset(df, test_name == t & grade %in% plain.grades.nok2 & achievement.level != 'U')
  d.cr <- df.t %>% group_by(school, grade, subject, test_name) %>% do(b_and_above(.))
	p <- single_test_bar_percs_plot(df.t, d.cr, t)
  save_plot_as_pdf(p, paste0("2014-15 ", t, " 3-8 Scores by Grades"))
	
	df.t <- subset(df, test_name == t & grade %in% total.grades.nok2 & achievement.level != 'U')
  d.cr <- df.t %>% group_by(school, grade, subject, test_name) %>% do(b_and_above(.))
	p <- single_test_bar_percs_plot(df.t, d.cr, t)
  save_plot_as_pdf(p, paste0("2014-15 ", t, " 3-8 Scores by Small Schools"))
  
  if(!t %in% c('L14', 'L15', 'MLQ1')){
    df.t <- subset(df, test_name == t & grade %in% k2.grades & achievement.level != 'U')
    d.cr <- df.t %>% group_by(school, grade, subject, test_name) %>% do(m_and_above(.))
    p <- single_test_bar_percs_plot(df.t, d.cr, t) + scale_fill_manual(values=alPalette.light.lows.k2, guide=F)
    save_plot_as_pdf(p, paste0("2014-15 ", t, " PK-2 Scores by Grades"))
  }
}