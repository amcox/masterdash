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
# df.m$small.school <- as.factor(df.m$small.school)
# df.m$small.school <- reorder(df.m$small.school,
# 											new.order=c("RCAA68", "STA68", "DTA68", "SHA68",
# 																	"RCAA35", "STA35", "DTA35", "SCH35",
# 																	"RCAAK2", "STAK2", "DTAK2", "SCHK2")
# )
d.percs$school <- reorder(d.percs$school,
											new.order=c("RCAA", "STA", "DTA", "SCH", 'RSP')
)
d.percs <- d.percs[order(as.numeric(d.percs$school)),]
d.percs$test_name <- reorder(d.percs$test_name, new.order=test.order)

for (gc in unique(d.percs$grade.category)) {
	d.gc <- subset(d.percs, grade.category == gc)
	for (sub in unique(d.gc$subject)) {
		d.sub <- subset(d.gc, subject == sub)
    print(paste(gc, sub, sep=" "))
		p <- ggplot()+
				geom_bar(data=d.sub, aes(x=sped_category, y=perc,
								fill=reorder(achievement.level,
								new.order=c("A", "M", "B", "AB", "U"))), stat="identity"
				)+
				scale_y_continuous(labels=percent, breaks=seq(0,1,.1))+
				scale_fill_manual(values=alPalette, guide=F)+
				ylab("Percent of Scores")+
				xlab("SPED Category")+
				labs(title=paste0("SPED Benchmark Percents at Achievement Levels, ",
													gc, " ", sub
				))+
				theme_bw()+
				theme(axis.text.x=element_text(size=6, angle=90, vjust=0.5),
							axis.text.y=element_text(size=5),
							title=element_text(size=8)
				)+
				facet_grid(school ~ test_name)
		pdf(paste0("./../output/SPED Benchmark Roll-Up ", gc, " ", sub, " 2014-15.pdf"),
				width=10.5, height=7
		)
		print(p)
		dev.off()	
	}
}

# Export spreadsheet of data
  # With multiple sped categories
  d.w <- dcast(d.percs, ... ~ achievement.level)
  d.w$cr <- apply(d.w, 1, function(r) {
    as.numeric(r['A']) + as.numeric(r['M']) + as.numeric(r['B'])
  })
  save_df_as_csv(d.w, "SPED Achievement Level Percents, Multiple Categories")

  # With only sped/gened
  df.sped <- get_sped_scores_data(con)
  df.sped$grade.category <- cut_grade_categories(df.sped$grade)
  df.sped$small.school <- make_small_school_labels(df.sped)
  # Combine SPED labels
  df.sped$sped_category <- as.character(df.sped$sped_category)
  df.sped$sped_category[df.sped$sped_category != 'gened'] <- 'sped'
  # Make percents by achievement level
  d.percs <- df.sped %>% group_by(school, grade.category, subject, test_name, sped_category) %>% 
		do(percents_of_total_als(.$adj_achievement_level, 'achievement.level'))
  d.percs.all.s <- df.sped %>% group_by(grade.category, subject, test_name, sped_category) %>%
		do(percents_of_total_als(.$adj_achievement_level, 'achievement.level'))
  d.percs.all.s$school <- rep("all", nrow(d.percs.all.s))
  d.l <- rbind(d.percs, d.percs.all.s)
  d.l <- subset(d.l, subject %in% c("ela", "math")))
  d.w <- dcast(d.l, school + grade.category + test_name + sped_category ~ achievement.level, fun.aggregate=mean)
  d.w$cr <- apply(d.w, 1, function(r) {
    as.numeric(r['A']) + as.numeric(r['M']) + as.numeric(r['B'])
  })
  save_df_as_csv(d.w, "SPED Achievement Level Percents, Just GenEd and SPED")

