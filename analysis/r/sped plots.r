# Generate plots that compare SPED scores to GenEd score
library(plyr)
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

# SPED information
df.sped <- get_sped_scores_data(con)
df.sped <- data.frame(df.sped, stringsAsFactors=T)
df.sped <- data.frame(rapply(df.sped, as.factor, classes="character",
											how="replace")
)
df.sped$grade.category <- cut(df.sped$grade, c(-1, 2, 6, 9),
													labels=c("K2", "35", "68"), right=FALSE
)
df.sped$small.school <- apply(df.sped, 1, function(r){
	paste0(r['school'],r['grade.category'])
})


d.counts <- ddply(df.sped, .(school, grade.category, subject, test_name,
															sped_category, adj_achievement_level), 
														summarize, count=length(student_id)
)
d.counts.r <- dcast(d.counts, school + grade.category + subject + test_name +
										sped_category ~ adj_achievement_level
)
d.counts.r[is.na(d.counts.r)] <- 0
df <- cbind(d.counts.r[, 1:5], prop.table(as.matrix(d.counts.r[, 6:10]), 1))
df.m<- melt(df, id.vars=c("school", "grade.category", "subject", "test_name",
											"sped_category"),
											variable.name="achievement_level",
											value.name="perc"
)
df.m$achievement_level <- reorder(df.m$achievement_level, 
																	new.order=c("A", "M", "B", "AB", "U")
)
df.m <- df.m[order(as.numeric(df.m$achievement_level)),]
# df.m$small.school <- as.factor(df.m$small.school)
# df.m$small.school <- reorder(df.m$small.school,
# 											new.order=c("RCAA68", "STA68", "DTA68", "SHA68",
# 																	"RCAA35", "STA35", "DTA35", "SCH35",
# 																	"RCAAK2", "STAK2", "DTAK2", "SCHK2")
# )
df.m$school <- reorder(df.m$school,
											new.order=c("RCAA", "STA", "DTA", "SCH")
)
df.m <- df.m[order(as.numeric(df.m$school)),]
df.m$test_name <- reorder(df.m$test_name, new.order=test.order)

alPalette <- c("A"="#00D77B", "M"="#00BE61", "B"="#198D33", "AB"="#E5E167",
							"U"="#D16262"
)
test.order <- c("L13", "MLQ1", "MLQ2", "MLQ3", "B1", "MLQ4", "MLQ5", "B2",
								"MLQ6", "MLQ7", "B3", "PL", "L14", "B4"
)
d <- subset(df.m, subject == 'ela' & grade.category == '35')

for (gc in unique(df.m$grade.category)) {
	d.gc <- subset(df.m, grade.category == gc)
	for (sub in unique(d.gc$subject)) {
		d.sub <- subset(d.gc, subject == sub)
		p <- ggplot()+
				geom_bar(data=d.sub, aes(x=sped_category, y=perc,
								fill=reorder(achievement_level,
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
		pdf(paste0("output/SPED Benchmark Roll-Up ", gc, " ", sub, " 2013-14.pdf"),
				width=10.5, height=7
		)
		print(p)
		dev.off()	
	}
}