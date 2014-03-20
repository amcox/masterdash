# Makes two files for each test, facted by grade (or grade category) and
# subject, showing schools as bars.

library(ggplot2)
library(scales)
library(RColorBrewer)
library(gridExtra)

update_functions <- function() {
	old.wd <- getwd()
	setwd("functions")
	sapply(list.files(), source)
	setwd(old.wd)
}
update_functions()

df <- load_percs_long()

for (t in test.order){
	df.t <- subset(df, test==t & grade %in% plain.grades)
	pdf(paste0("../Output/2013 ", t, " Scores by Grades.pdf"), width=10, height=7)
	print(
	ggplot(df.t, aes(x=school, y=perc, fill=level))+
		geom_bar(stat="identity")+
		scale_x_discrete(limits=schools)+
		scale_y_continuous(labels = percent, breaks=seq(0,1,.1))+
		scale_fill_manual(values=alPalette, guide=F)+
		ylab("Percent of Scores")+
		xlab("School")+
		labs(title=paste0("2013 ", t, " Scores"))+
		facet_grid(subject ~ grade, labeller=short_labeller)+
		theme_bw()+
		theme(axis.text.x=element_text(size=5, angle=90, vjust=0.5),
					axis.text.y=element_text(size=6)
		)
	)
	dev.off()
	
	df.t <- subset(df, test==t & grade %in% total.grades)
	pdf(paste0("../Output/2013 ", t, " Scores by Small Schools.pdf"), width=10, height=7)
	print(
	ggplot(df.t, aes(x=school, y=perc, fill=level))+
		geom_bar(stat="identity")+
		scale_x_discrete(limits=schools)+
		scale_y_continuous(labels = percent, breaks=seq(0,1,.1))+
		scale_fill_manual(values=alPalette, guide=F)+
		ylab("Percent of Scores")+
		xlab("School")+
		labs(title=paste0("2013 ", t, " Scores"))+
		facet_grid(subject ~ grade, labeller=short_labeller)+
		theme_bw()+
		theme(axis.text.x=element_text(size=5, angle=90, vjust=0.5),
					axis.text.y=element_text(size=6)
		)
	)
	dev.off()
}