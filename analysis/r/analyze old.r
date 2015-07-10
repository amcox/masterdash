library(gdata)
library(plyr)
library(dplyr)
library(reshape2)
library(car)
library(compute.es)
library(ggplot2)
library(scales)
library(gridExtra)

df.tests <- dbGetQuery(con, "select * from tests")
df.students <- dbGetQuery(con, "select * from students")
df.enrollments <- dbGetQuery(con, "select * from enrollments")
df.scores <- dbGetQuery(con, "select * from scores")
df.teachers <- dbGetQuery(con, "select * from teachers")

scores.enrollments.query <- "SELECT s.*,
		e.subject subject,
		e.grade grade,
		e.school school,
		e.section section,
		t.teacher_number teacher_number,
		t.name teacher_name,
		tests.name test_name,
		tests.order test_order
FROM enrollments e
JOIN scores s ON s.student_id = e.student_id AND e.subject = s.subject
JOIN teachers t ON t.id = e.teacher_id
JOIN tests ON tests.id = s.test_id"
df.se <- dbGetQuery(con, scores.enrollments.query)

dsum.percent <- ddply(df.se, .(teacher_number, teacher_name, school, subject, test_name, grade), summarize, average=mean(percent))
dsum.percent$test_name <- factor(dsum.percent$test_name)
dsum.percent$test_name <- reorder(dsum.percent$test_name, new.order=test.order)
dsum.percent <- dcast(dsum.percent, teacher_number + teacher_name + school + subject + grade ~ test_name)
write.csv(dsum.percent, "average percent correct.csv", row.names=F, na="")

# Get z score for percent correct
test.info <- ddply(df.se, .(test_name, subject, grade), summarize, overall_mean=mean(percent), sd=sd(percent))
dsum.percent <- ddply(df.se, .(teacher_number, teacher_name, school, subject, test_name, grade), summarize, average=mean(percent))
dsum.percent$test_name <- factor(dsum.percent$test_name)
dsum.percent$test_name <- reorder(dsum.percent$test_name, new.order=test.order)
dsum.percent <- merge(dsum.percent, test.info)
dsum.percent$z.score <- apply(dsum.percent, 1, function(r){
	(as.numeric(r[['average']]) - as.numeric(r[['overall_mean']]))/as.numeric(r[['sd']])
})
dsum.percent <- dcast(dsum.percent,
											teacher_number + teacher_name + school + subject + grade ~ test_name,
											value.var="z.score"
)
write.csv(dsum.percent, "percent_correct_z_scores.csv", row.names=F, na="")

dsum.ai <- ddply(df.se, .(teacher_number, teacher_name, school, subject, test_name, grade), summarize, ai=mean(ai_points))
dsum.ai$test_name <- factor(dsum.ai$test_name)
dsum.ai$test_name <- reorder(dsum.ai$test_name, new.order=test.order)
dsum.ai <- dcast(dsum.ai, teacher_number + teacher_name + school + subject + grade ~ test_name)
write.csv(dsum.ai, "ai.csv", row.names=F, na="")

dsum.cr <- ddply(df.se, .(teacher_number, teacher_name, school, subject, test_name), summarize, cr=length(subset(on_level, on_level==T))/length(on_level) )
dsum.cr$test_name <- factor(dsum.cr$test_name)
dsum.cr$test_name <- reorder(dsum.cr$test_name, new.order=test.order)
dsum.cr <- dcast(dsum.cr, teacher_number + teacher_name + school + subject ~ test_name)
write.csv(dsum.cr, "cr.csv", row.names=F, na="")

# CR, but by grade-school, not teacher
scores.enrollments.query <- "SELECT s.*,
		e.subject subject,
		e.grade grade,
		e.school school,
		e.section section,
		t.teacher_number teacher_number,
		t.name teacher_name,
		tests.name test_name,
		tests.order test_order
FROM (
	SELECT student_id,
		subject,
		school,
		teacher_id,
		MAX(grade) grade,
		year,
		MAX(section) section,
		type
	FROM enrollments
	GROUP BY student_id, subject, school, teacher_id, year, type
) e
JOIN scores s ON s.student_id = e.student_id AND e.subject = s.subject
JOIN teachers t ON t.id = e.teacher_id
JOIN tests ON tests.id = s.test_id"
df.sg <- dbGetQuery(con, scores.enrollments.query)
dsum.cr <- ddply(df.sg, .(school, grade, subject, test_name), summarize, cr=length(subset(on_level, on_level==T))/length(on_level) )
dsum.cr$test_name <- factor(dsum.cr$test_name)
dsum.cr$test_name <- reorder(dsum.cr$test_name, new.order=test.order)
dsum.cr <- dcast(dsum.cr, school + grade + subject ~ test_name)
write.csv(dsum.cr, "cr_by_school_grade.csv", row.names=F, na="")

# Make figures for each teacher
# Bar graphs for all assessments in the year
d.s <- subset(df.se, teacher_name=='Leist, Kate')
d.s.s <- d.s[,c("id", "achievement_level", "subject", "test_name", "grade", "percent")]
d.s.s$achievement_level <- gsub("B2", "A", d.s.s$achievement_level)
d.s.s$achievement_level <- gsub("AB2", "B", d.s.s$achievement_level)
d.s.s$achievement_level <- gsub("PF", "U", d.s.s$achievement_level)
d.s.s$achievement_level <- gsub("F", "U", d.s.s$achievement_level)
d.s.s$achievement_level <- gsub("ES", "A", d.s.s$achievement_level)
d.s.s$achievement_level <- gsub("MS", "B", d.s.s$achievement_level)
d.s.s$achievement_level <- gsub("WTS", "AB", d.s.s$achievement_level)
d.props <- ddply(d.s.s, .(grade, subject), function(d){
	data.frame(prop.table(table(d$test_name, d$achievement_level), 1))
})
names(d.props) <- c("grade", "subject", "test", "achievement_level", "perc")
p.bars <- ggplot()+
	geom_bar(data=d.props, aes(x=test, y=perc, fill=achievement_level), stat="identity")+
	geom_boxplot(data=d.s.s, aes(x=test_name, y=percent), alpha=0.01, width=0.5)+
	# geom_jitter(data=d.s.s, aes(x=test_name, y=percent), position=position_jitter(width=.25, height=0), shape=1, alpha=0.5)+
	scale_x_discrete(limits=test.order)+
	scale_y_continuous(labels=percent, breaks=seq(0,1,.1))+
	scale_fill_manual(values=alPalette, guide=F)+
	ylab("Percent of Scores")+
	xlab("Assessment")+
	labs(title="2013-14 Benchmark Scores")+
	theme_bw()+
	theme(axis.text.x=element_text(size = 6),
				axis.text.y=element_text(size=6),
				title=element_text(size=7)
	)+
	facet_grid(grade~subject)

teacher.summary.plot.38 <- function(teacher.name, se.data, gsse.data, star.data,
																		highlights, star.means, obs.data, obs.means,
																		all.obs.means
																		) {
	print(paste0("starting ", teacher.name))
	alPalette <- c("A"="#00D77B", "M"="#00BE61", "B"="#198D33", "AB"="#E5E167", "U"="#D16262")
	make.num.for.z <- function(r){
		if(is.na(r[['percent']])){
			return(as.numeric(r[['achievement_code']]))
		}else{
			return(as.numeric(r[['percent']]))
		}
	}
		
	se.t <- subset(se.data, teacher_name==teacher.name)
	se.t.c <- se.t[,c("id", "achievement_level", "subject", "test_name", "grade", "percent")]
	d.props <- ddply(se.t.c, .(grade, subject), function(d){
		data.frame(prop.table(table(d$test_name, d$achievement_level), 1))
	})
	names(d.props) <- c("grade", "subject", "test", "achievement_level", "perc")
	d.props$achievement_level <- reorder(d.props$achievement_level,
																new.order=c("A", "M", "B", "AB", "U")
	)
	d.props <- d.props[order(as.numeric(d.props$achievement_level)),]
	
	b.above <- subset(d.props, achievement_level %in% c("A", "M", "B"))
	b.above <- ddply(b.above, .(grade, subject, test), summarize, perc=sum(perc))
	
	p.bars <- ggplot()+
		geom_bar(data=d.props, aes(x=test, y=perc, fill=reorder(achievement_level, new.order=c("A", "M", "B", "AB", "U"))), stat="identity")+
		geom_boxplot(data=se.t.c, aes(x=test_name, y=percent), alpha=0.01, width=0.5)+
		geom_bar(data=highlights, aes(x=test, y=perc),  fill="white", stat="identity", alpha=.4)+
		# geom_hline(data=subset(b.above, test=="L13"), aes(yintercept=perc+.1), linetype=3)+
		scale_x_discrete(limits=test.order)+
		scale_y_continuous(labels=percent, breaks=seq(0,1,.1))+
		scale_fill_manual(values=alPalette, guide=F)+
		ylab("Percent of Scores")+
		xlab("Assessment")+
		labs(title="Benchmark Percents at Achievement Levels and Percent Correct Boxplot")+
		theme_bw()+
		theme(axis.text.x=element_text(size=6, angle=90, vjust=0.5),
					axis.text.y=element_text(size=6),
					title=element_text(size=7)
		)+
		facet_grid(subject + grade ~ .)
	b.above.l13 <- subset(b.above, test=="L13")
	if(nrow(b.above.l13) > 0){
		p.bars  <- p.bars + geom_hline(data=b.above.l13,
																		aes(yintercept=perc+.1), linetype=3
		)
	}

	# z-scores plot
	al.numbers <- data.frame(achievement_level=c("A", "M", "B", "AB", "U", "B2", "AB2", "F", "PF", "ES", "MS", "WTS"),
													achievement_code=c(1, 0.75, 0.5, 0.25, 0, 1, 0.5, 0.25, 0, 1, 0.5, 1)
	)
	gsse.data$num.for.z <- apply(gsse.data, 1, make.num.for.z)
	test.info <- ddply(gsse.data, .(test_name, subject, grade), summarize, overall_mean=mean(num.for.z), sd=sd(num.for.z))
	se.t.c <- se.t[,c("id", "teacher_name", "achievement_level", "subject", "test_name", "grade", "percent", "scaled_score")]
	se.t.c <- merge(se.t.c, al.numbers)
	se.t.c$num.for.z <- apply(se.t.c, 1, make.num.for.z)
	d.mean <- ddply(se.t.c, .(subject, test_name, grade), summarize, average=mean(num.for.z))
	d.mean <- merge(d.mean, test.info)
	d.mean$z.score <- apply(d.mean, 1, function(r){
		(as.numeric(r[['average']]) - as.numeric(r[['overall_mean']]))/as.numeric(r[['sd']])
	})
	color.codes <- data.frame(test_name=c("L13", "MLQ1", "MLQ2", "MLQ3", "B1", "MLQ4", "MLQ5", "B2", "MLQ6", "MLQ7", "B3", "PL", "L14", "B4"),
														color.code=c("blue", "black", "black", "black", "blue", "black", "black", "blue", "black", "black", "blue", "black", "blue", "black")
	)
	d.mean <- merge(d.mean, color.codes)
	p.z <- ggplot(d.mean)+
		geom_line(aes(x=test_name, y=z.score, group=grade))+
		geom_point(aes(x=test_name, y=z.score, color=color.code), size=3)+
		geom_hline(yintercept=0)+
		scale_color_manual(values=c("black", "#00A6FF"), guide=F)+
		scale_y_continuous()+
		scale_x_discrete(limits=test.order)+
		ylab("Z Score")+
		labs(title="Benchmark Percent Correct Z-Scores")+
		theme_bw()+
		theme(axis.text.x=element_text(size=6, angle=90, vjust=0.5),
					axis.text.y=element_text(size=6),
					axis.title.x=element_blank(),
					title=element_text(size=7)
		)+
		facet_grid(subject + grade ~ .)
		
	
	d.star <- subset(star.data, teacher_name==teacher.name)
	star.plot <- function(d, all.means) {
		t.means <- ddply(d, .(grade, subject.x, subject.y), summarize,
													mean=mean(last.modeled.gap, na.rm=T)
		)
		all.means.sub <- subset(all.means, subject.y %in% unique(d$subject.y) & 
														subject.x %in% unique(d$subject.x) &
														grade %in% unique(d$grade) &
														!is.na(sd)
		)
		ggplot(d, aes(x=last.modeled.gap))+
			geom_bar(aes(y = ..density..), colour="black", binwidth=1)+
			geom_vline(data=t.means, mapping=aes(xintercept=mean), color="red")+
			geom_vline(data=all.means.sub, mapping=aes(xintercept=c(mean+sd,mean,mean-sd)),
								color="blue", linetype=c(2,1,2)
			)+
			scale_y_continuous(labels=percent)+
			scale_x_continuous(breaks=seq(-10,10,1))+
			theme_bw()+
			labs(title=paste0("STAR Gap from Grade Level, Latest Test"),
						x="STAR Gap from Grade Level in Years (negative is below)",
						y="Percent of Students"
			)+
			theme(title=element_text(size=6),
						axis.text.y=element_text(size=6),
						axis.text.x=element_text(size=6)
			)+
			facet_grid(subject.y + grade ~ subject.x)
	}
	if(nrow(d.star)>0){
		stars <- star.plot(d.star, star.means)
	}else{
		stars <- grob()
	}
	
	d.obs <- subset(obs.data, name==teacher.name)
	if(nrow(d.obs) > 0){
		obs.means.s <- drop.levels(subset(obs.means, small_school %in% unique(d.obs$small_school)))
		obs.means.a <- rbind(obs.means.s, all.obs.means)
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
	}else{
		p.obs <- grob()
	}
		
	right.side <- arrangeGrob(p.z, stars, p.obs, ncol=1)
	p <- arrangeGrob(p.bars, right.side, ncol=2,
										# widths=c(0.67, 0.33),
										main=paste0("\n2013-14 Teacher Profile - ", teacher.name)
	)
	return(p)
}
plot.teacher.summary <- function(teacher.name, se.data, gsse.data, star.data,
																	highlights, star.means, obs.data, obs.means,
																	all.obs.means) {
	p <- teacher.summary.plot.38(teacher.name, se.data, gsse.data, star.data,
																	highlights, star.means, obs.data, obs.means,
																	all.obs.means)
	pdf(paste0("output/", teacher.name, " Profile 2013-14.pdf"), width=10.5, height=7)
	print(p)
	dev.off()
}

scores.enrollments.query <- "SELECT s.*,
		e.subject subject,
		e.grade grade,
		e.school school,
		e.section section,
		t.teacher_number teacher_number,
		t.name teacher_name,
		tests.name test_name,
		tests.order test_order
FROM enrollments e
JOIN scores s ON s.student_id = e.student_id AND e.subject = s.subject
JOIN teachers t ON t.id = e.teacher_id
JOIN tests ON tests.id = s.test_id"
df.se <- dbGetQuery(con, scores.enrollments.query)
se.data$achievement_level <- gsub("AB2", "B", se.data$achievement_level)
se.data$achievement_level <- gsub("B2", "A", se.data$achievement_level)
se.data$achievement_level <- gsub("PF", "U", se.data$achievement_level)
se.data$achievement_level <- gsub("F", "U", se.data$achievement_level)
se.data$achievement_level <- gsub("ES", "A", se.data$achievement_level)
se.data$achievement_level <- gsub("MS", "B", se.data$achievement_level)
se.data$achievement_level <- gsub("WTS", "AB", se.data$achievement_level)
gs.scores.enrollments.query <- "SELECT s.*,
		e.subject subject,
		e.grade grade,
		e.school school,
		e.section section,
		t.teacher_number teacher_number,
		t.name teacher_name,
		tests.name test_name,
		tests.order test_order
FROM (
	SELECT student_id,
		subject,
		school,
		teacher_id,
		MAX(grade) grade,
		year,
		MAX(section) section,
		type
	FROM enrollments
	GROUP BY student_id, subject, school, teacher_id, year, type
) e
JOIN scores s ON s.student_id = e.student_id AND e.subject = s.subject
JOIN teachers t ON t.id = e.teacher_id
JOIN tests ON tests.id = s.test_id"
df.gsse <- dbGetQuery(con, gs.scores.enrollments.query)
gsse.data$achievement_level <- gsub("AB2", "B", gsse.data$achievement_level)
gsse.data$achievement_level <- gsub("B2", "A", gsse.data$achievement_level)
gsse.data$achievement_level <- gsub("PF", "U", gsse.data$achievement_level)
gsse.data$achievement_level <- gsub("F", "U", gsse.data$achievement_level)
gsse.data$achievement_level <- gsub("ES", "A", gsse.data$achievement_level)
gsse.data$achievement_level <- gsub("MS", "B", gsse.data$achievement_level)
gsse.data$achievement_level <- gsub("WTS", "AB", gsse.data$achievement_level)
al.numbers <- data.frame(achievement_level=c("A", "M", "B", "AB", "U", "B2", "AB2", "F", "PF", "ES", "MS", "WTS"),
												achievement_code=c(1, 0.75, 0.5, 0.25, 0, 1, 0.5, 0.25, 0, 1, 0.5, 1)
)
df.gsse <- merge(df.gsse, al.numbers)
highlights <- data.frame(test=c("MLQ1", "MLQ2", "MLQ3", "MLQ4", "MLQ5", "MLQ6", "MLQ7"), perc=c(1,1,1,1,1,1,1))
df.star <- read.csv(file="csvs/student star summary.csv", head=TRUE, na.string=c("", " ", "  "))
enrollments.query <- "SELECT
		s.student_number,
		e.subject subject,
		e.grade grade,
		e.school school,
		e.section section,
		t.teacher_number teacher_number,
		t.name teacher_name
FROM enrollments e
JOIN teachers t ON t.id = e.teacher_id
JOIN students s ON s.id = e.student_id"
df.e <- dbGetQuery(con, enrollments.query)
df.star.e <- merge(df.star, df.e, by.x="StudentId", by.y="student_number")
students.query <- "SELECT DISTINCT
		s.student_number,
		e.subject subject,
		e.grade grade
FROM enrollments e
JOIN students s ON s.id = e.student_id"
df.students <- dbGetQuery(con, students.query)
df.star.s <- merge(df.star, df.students, by.x="StudentId", by.y="student_number")
d.star.means <- ddply(df.star.s, .(subject.x, subject.y, grade), summarize,
											mean=mean(last.modeled.gap, na.rm=T),
											sd=sd(last.modeled.gap, na.rm=T)
)
obs.query <- "SELECT
		o.*,
		t.*
FROM observations o
JOIN teachers t ON t.id = o.teacher_id"
df.obs <- dbGetQuery(con, obs.query)
df.obs$quarter <- factor(df.obs$quarter)
d.obs.means <- ddply(df.obs, .(small_school, quarter), summarize,
										mean=mean(score, na.rm=T),
										sd=sd(score, na.rm=T)	
)
all.obs.means <- ddply(df.obs, .(quarter), summarize,
										mean=mean(score, na.rm=T),
										sd=sd(score, na.rm=T)	
)
all.obs.means$small_school <- "Network"

teachers <- unique(df.se$teacher_name)
lapply(teachers, plot.teacher.summary, se.data=df.se, gsse.data=df.gsse,
			star.data=df.star.e, highlights=highlights, star.means=d.star.means,
			obs.data=df.obs, obs.means=d.obs.means, all.obs.means=all.obs.means
)

# SPED information
sped.scores.query <- "SELECT *,
		CASE achievement_level
			WHEN 'B2' THEN 'M'
			WHEN 'AB2' THEN 'B'
			WHEN 'F' THEN 'AB'
			WHEN 'PF' THEN 'U'
			ELSE achievement_level
		END adj_achievement_level,
		CASE
			WHEN state_test = 'LAA' THEN 'laa'
			WHEN iep_speech_only THEN 'speech_only'
			WHEN la_sped = 1 THEN 'iep_no_speech'
			ELSE 'gened'
		END sped_category
FROM (
	SELECT s.*,
			st.la_sped,
			st.iep_speech_only,
			st.student_number,
			CASE e.subject
	    WHEN 'ela' THEN
				st.state_test_ela
	    WHEN 'math' THEN
				st.state_test_math
	    WHEN 'sci' THEN
				st.state_test_sci
	    WHEN 'soc' THEN
				st.state_test_soc
	    ELSE NULL
		END state_test,
			e.subject subject,
			e.grade grade,
			e.school school,
			tests.name test_name,
			tests.order test_order
	FROM (
		SELECT student_id,
			subject,
			school,
			MAX(grade) grade,
			year,
			type
		FROM enrollments
		GROUP BY student_id, subject, school, year, type
	) e
	JOIN scores s ON s.student_id = e.student_id AND e.subject = s.subject
	JOIN tests ON tests.id = s.test_id
	JOIN students st ON s.student_id = st.id
) scores_info
WHERE achievement_level NOT IN ('WTS', 'MS', 'ES')"
df.sped <- data.frame(dbGetQuery(con, sped.scores.query), stringsAsFactors=T)
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



