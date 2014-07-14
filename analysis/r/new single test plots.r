# File for the new style requested by Gary.

library(plyr)
library(dplyr)
library(gdata)
library(reshape2)
library(ggplot2)
library(scales)
library(gridExtra)
library(RColorBrewer)

update_functions <- function() {
	old.wd <- getwd()
	setwd("functions")
	sapply(list.files(), source)
	setwd(old.wd)
}
update_functions()

con <- prepare_connection()
df <- create_student_school_scores_roll_up(con)

# Grab a sample data set. I'll have to make loops for this once the format is approved.
d <- subset(df, test_name == 'B3' & subject == 'ela' & grade %in% c(plain.grades.leap, '3_8') & achievement.level != 'U')

# Make totals for the labels
d.cr <- d %>% group_by(school, grade, subject, test_name) %>% do(b_and_above(.))

# Version with greens for all schools
p.test <- ggplot()+
		geom_bar(data=d, aes(x=school, y=perc, fill=achievement.level), stat="identity")+
    geom_text(data=d.cr, aes(label=percent(round(perc.cr, digits=2)), x=school, y=perc.cr +.01), size=2.75)+
		scale_x_discrete(limits=schools)+
		scale_y_continuous(labels=percent, breaks=seq(0,1,.1), limits=c(0,1))+
		scale_fill_manual(values=alPalette.light.lows, guide=F)+
		labs(title=paste0('2013-14 Benchmark #3 ELA'),
      x='School',
      y='Percent of Scores'
    )+
		facet_grid(~ grade, labeller=short_labeller)+
		theme_bw()+
		theme(axis.text.x=element_text(size=11, angle=90, vjust=0.5),
					axis.text.y=element_text(size=12)
		)
    
save_plot_as_pdf(p.test, '2013-14 B3 ELA Scores, New Format')

# Version with different colors for different schools
gary.school.pal <- c('#6BADDA', '#F48E4C', '#B4B4B4', '#FFC83E', '#70A75A')
al.alpha.pal <- c('A'=.5, 'M'=.75, 'B'=1, 'AB'=.2, 'U'=0)
p.test <- ggplot()+
		geom_bar(data=d, aes(x=school, y=perc, alpha=achievement.level, fill=school), stat="identity")+
    geom_text(data=d.cr, aes(label=percent(round(perc.cr, digits=2)), x=school, y=perc.cr +.01), size=2.5)+
		scale_x_discrete(limits=schools)+
		scale_y_continuous(labels=percent, breaks=seq(0,1,.1), limits=c(0,1))+
		scale_alpha_manual(values=al.alpha.pal, guide=F)+
    # scale_fill_brewer(palette="Set1", guide=F)+
    scale_fill_manual(values=gary.school.pal, guide=F)+
		labs(title=paste0('2013-14 Benchmark #3 ELA'),
      x='School',
      y='Percent of Scores'
    )+
		facet_grid(~ grade, labeller=short_labeller)+
		theme_bw()+
		theme(axis.text.x=element_text(size=11, angle=90, vjust=0.5),
					axis.text.y=element_text(size=12),
          panel.margin = unit(1.5, "lines")
		)
save_plot_as_pdf(p.test, '2013-14 B3 ELA Scores, New Format Multicolor')