# Generate plots that compare SPED scores to GenEd score
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

con <- prepare_connection()

# Get scores
df.sped <- get_sped_scores_data(con)
df.sped$grade.category <- cut_grade_categories(df.sped$grade)
df.sped$small.school <- make_small_school_labels(df.sped)

# Make percents by achievement level
d.percs <- df.sped %>% group_by(school, grade.category, subject, test_name, sped_category) %>%
 do(percents_of_total_als(.$adj_achievement_level, 'achievement.level'))

# Sort the percents
d.percs$achievement.level <- reorder(d.percs$achievement.level, 
																	new.order=c("A", "M", "B", "AB", "U")
)
d.percs <- d.percs[order(as.numeric(d.percs$achievement.level)),]

d.percs$school <- reorder(d.percs$school,
											new.order=c("RCAA", "STA", "DTA", "SCH")
)
d.percs <- d.percs[order(as.numeric(d.percs$school)),]
d.percs$test_name <- reorder(d.percs$test_name, new.order=test.order)

d.percs <- drop.levels(subset(d.percs, test_name %in% c("L13", "L14") & subject %in% c('ela', 'math')))

make_sped_graph <- function(d, gc, sub) {
  p <- ggplot()+
  	geom_bar(data=d, aes(x=sped_category, y=perc,
  					fill=reorder(achievement.level,
  					new.order=c("A", "M", "B", "AB", "U"))), stat="identity"
  	)+
  	scale_y_continuous(labels=percent, breaks=seq(0,1,.2))+
  	scale_fill_manual(values=alPalette, guide=F)+
  	ylab("Percent of Scores")+
  	xlab("SPED Category")+
  	labs(title=paste0(long_labeller('grade', gc), " ", long_labeller('subject', sub)))+
  	theme_bw()+
  	theme(axis.text.x=element_text(size=6, angle=90, vjust=0.5),
  				axis.text.y=element_text(size=4.5),
  				title=element_text(size=8),
          axis.title.x=element_blank(),
          axis.title.y=element_blank()
  	)+
  	facet_grid(school ~ test_name)
  return(p)
}

plots <- sapply(levels(interaction(unique(d.percs$grade.category), unique(d.percs$subject))), function(x){NULL})
for(gc in unique(d.percs$grade.category)){
  for(sub in unique(d.percs$subject)){
  		d.sub <- subset(d.percs, subject == sub & grade.category == gc)
  		plots[[paste(gc,sub,sep=".")]] <- make_sped_graph(d.sub, gc, sub)
  }
}
p <- do.call(arrangeGrob, c(plots, main=paste0("\nSPED i/LEAP Percents at Achievement Levels"),
												left="\nPercent of Students",
												sub="SPED Category\n",
												ncol=2)
)
save_plot_as_pdf(p, paste0("SPED i-LEAP Roll-Up 2014 for Board"), wide=F)
