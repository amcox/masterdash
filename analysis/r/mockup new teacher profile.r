# Generate teacher profile PDFs for each teacher
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

# Get scores by class enrollments
df.se <- get_scores_enrollments_data(con)
df.se$achievement_level <- make_adjusted_als(df.se$achievement_level)

# Get scores by school enrollments
df.gsse <- get_school_scores_enrollments_data(con)
df.gsse$achievement_level <- make_adjusted_als(df.gsse$achievement_level)

# Convert LEAP achievement levels to numbers so they can get a z score
al.numbers <- data.frame(achievement_level=c("A", "M", "B", "AB", "U", "B2", "AB2", "F", "PF", "ES", "MS", "WTS"),
												achievement_code=c(1, 0.75, 0.5, 0.25, 0, 1, 0.5, 0.25, 0, 1, 0.5, 1)
)
df.gsse <- merge(df.gsse, al.numbers)

# Get STAR data
df.star <- read.csv(file="../data/student STAR data with LEAP prediction.csv", head=TRUE, na.string=c("", " ", "  "))
df.e <- get_enrollments_data(con)
df.star.e <- merge(df.star, df.e, by.x="StudentId", by.y="student_number")
df.students <- get_students_data(con)
df.star.s <- merge(df.star, df.students, by.x="StudentId", by.y="student_number")
d.star.means <- ddply(df.star.s, .(subject.x, subject.y, grade.y), summarize,
											mean=mean(last.modeled.gap, na.rm=T),
											sd=sd(last.modeled.gap, na.rm=T)
)

# Get observation data
df.obs <- get_observation_data(con)
df.obs$quarter <- factor(df.obs$quarter)
all.obs.means <- ddply(df.obs, .(quarter), summarize,
										mean=mean(score, na.rm=T),
										sd=sd(score, na.rm=T)	
)
all.obs.means$small_school <- "Network"

# Do the actual plotting for each teacher
# teachers <- unique(df.se$teacher_name)
# lapply(teachers, plot.teacher.summary, se.data=df.se, gsse.data=df.gsse,
#       star.data=df.star.e, highlights=highlights, star.means=d.star.means,
#       obs.data=df.obs, obs.means=d.obs.means, all.obs.means=all.obs.means
# )

teacher.name <- 'Bonneau, Nicole'

make.num.for.z <- function(r){
	if(is.na(r[['percent']])){
		return(as.numeric(r[['achievement_code']]))
	}else{
		return(as.numeric(r[['percent']]))
	}
}

se.t <- subset(se.data, teacher_name==teacher.name)
se.t.c <- se.t[,c("id", "teacher_name", "achievement_level", "subject", "test_name", "grade", "percent", "scaled_score")]
se.t.c <- merge(se.t.c, al.numbers)
se.t.c$perc_or_al_num <- apply(se.t.c, 1, function(r){
  if(is.na(r['percent'])){
    return(as.numeric(r['achievement_code']))
  }else{
    return(as.numeric(r['percent']))
  }
})
d.props <- ddply(se.t.c, .(), function(d){
	data.frame(prop.table(table(d$test_name, d$achievement_level), 1))
})
names(d.props) <- c('foo', "test", "achievement_level", "perc")
d.props <- d.props[, names(d.props) != 'foo']
d.props$achievement_level <- reorder(d.props$achievement_level,
															new.order=c("A", "M", "B", "AB", "U")
)
d.props <- d.props[order(as.numeric(d.props$achievement_level)),]
d.props <- subset(d.props, test %in% c('L13', 'B1', 'B2', 'B3'))

b.above <- subset(d.props, achievement_level %in% c("A", "M", "B"))
b.above <- ddply(b.above, .(test), summarize, perc=sum(perc))

p.bars <- ggplot()+
	geom_bar(data=subset(d.props, achievement_level != 'U'), aes(x=test, y=perc, fill=reorder(achievement_level, new.order=c("A", "M", "B", "AB", "U"))), stat="identity")+
	scale_x_discrete(limits=c('L13', 'B1', 'B2', 'B3', 'L14'))+
	scale_y_continuous(labels=percent, breaks=seq(0,1,.1), limits=c(0,1))+
	scale_fill_manual(values=alPalette.light.lows, guide=F)+
	ylab("Percent of Scores")+
	xlab("Assessment")+
	labs(title="Benchmark Percents at Achievement Levels and Percent Correct Boxplot")+
	theme_bw()+
	theme(axis.text.x=element_text(size=6, angle=90, vjust=0.5),
				axis.text.y=element_text(size=6),
				title=element_text(size=7)
	)
b.above.l13 <- subset(b.above, test=="L13")
if(nrow(b.above.l13) > 0){
	p.bars  <- p.bars + geom_hline(data=b.above.l13,
																	aes(yintercept=perc+.1), linetype=3
	)
}

# Observation scores plot
d.obs <- subset(obs.data, name==teacher.name)
obs.means.a <- all.obs.means
p.obs <- ggplot()+
	geom_point(data=obs.means.a, aes(x=quarter, y=mean, color=small_school),
							shape=1, position=position_dodge(.1)
	)+
	geom_errorbar(data=obs.means.a, aes(x=quarter, ymin=mean-sd, ymax=mean+sd,
								color=small_school), width=0.5, position=position_dodge(.1)
	)+
	geom_point(data=d.obs, aes(x=quarter, y=score), shape=18, size=4, color="red")+
	scale_y_continuous(limits=c(1,5), breaks=seq(1,5,0.5))+
	scale_color_manual(values=c("#1B9E77", "#D95F02"), name="Mean and SD")+
	labs(title="Quarterly Observation Scores",
			x="Quarter",
			y="Score"
	)+
	coord_flip()+
	theme_bw()+
	theme(title=element_text(size=6),
				axis.text.y=element_text(size=6),
				axis.text.x=element_text(size=6),
				legend.title=element_text(size=6),
				legend.text=element_text(size=6)
	)
  
# STAR Plot gap growth hist
d.star <- subset(star.data, teacher_name==teacher.name)
t.means <- ddply(d.star, .(subject.x), summarize,
											mean=mean(modeled.year.gap.growth, na.rm=T)
)
ggplot(d.star, aes(x=modeled.year.gap.growth))+
	geom_bar(aes(y = ..density..), colour="black", binwidth=1)+
  geom_vline(data=t.means, mapping=aes(xintercept=mean), color="red")+
	scale_y_continuous(labels=percent)+
	scale_x_continuous(breaks=seq(-10,10,1), limits=c(-5, 5))+
	theme_bw()+
	labs(title='',
				x="STAR Modeled Year Gap Growth",
				y="Percent of Students"
	)+
	theme(title=element_text(size=6),
				axis.text.y=element_text(size=6),
				axis.text.x=element_text(size=6)
	)+
	facet_grid( ~ subject.x)
  
# STAR Plot gap growth hist
d.star <- subset(star.data, teacher_name==teacher.name)
t.means <- ddply(d.star, .(subject.x), summarize,
											mean=mean(modeled.year.gap.growth, na.rm=T)
)
ggplot(d.star, aes(x=modeled.year.gap.growth))+
	geom_bar(aes(y = ..density..), colour="black", binwidth=1)+
  geom_vline(data=t.means, mapping=aes(xintercept=mean), color="red")+
	scale_y_continuous(labels=percent)+
	scale_x_continuous(breaks=seq(-10,10,1), limits=c(-5, 5))+
	theme_bw()+
	labs(title='',
				x="STAR Modeled Year Gap Growth",
				y="Percent of Students"
	)+
	theme(title=element_text(size=6),
				axis.text.y=element_text(size=6),
				axis.text.x=element_text(size=6)
	)+
	facet_grid( ~ subject.x)