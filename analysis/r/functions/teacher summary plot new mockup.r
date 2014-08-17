teacher.summary.plot.38.mockup <- function(teacher.name, se.data, gsse.data, star.data,
																		highlights, star.means, obs.data, obs.means,
																		all.obs.means
																		) {
	print(paste0("starting ", teacher.name))
  
	make.num.for.z <- function(r){
		if(is.na(r[['percent']])){
			return(as.numeric(r[['achievement_code']]))
		}else{
			return(as.numeric(r[['percent']]))
		}
	}
		
  # AL bars plot for DCI tests
  se.t <- subset(se.data, teacher_name==teacher.name)
	se.t.c <- se.t[,c("id", "teacher_name", "achievement_level", "subject", "test_name", "grade", "percent", "scaled_score")]
	se.t.c <- merge(se.t.c, al.numbers)
  se.t.c$perc_or_al_num <- apply(se.t.c, 1, function(r){
    if(is.na(r['percent'])){
      return(as.numeric(r['achievement_code']))
    }else{
      return(as.numerics(r['percent']))
    }
  })
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
		geom_boxplot(data=se.t.c, aes(x=test_name, y=perc_or_al_num), alpha=0.01, width=0.5)+
		geom_bar(data=highlights, aes(x=test, y=perc), fill="white", stat="identity", alpha=.4)+
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

	# Z-scores plot
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
		
	
  # STAR plots
  d.star <- subset(star.data, teacher_name==teacher.name)
	star.plot <- function(d, all.means) {
		t.means <- ddply(d, .(grade.y, subject.x, subject.y), summarize,
													mean=mean(last.modeled.gap, na.rm=T)
		)
		all.means.sub <- subset(all.means, subject.y %in% unique(d$subject.y) & 
														subject.x %in% unique(d$subject.x) &
														grade.y %in% unique(d$grade.y) &
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
			labs(title=paste0("STAR Gap from Grade Level, Latest Modeled Value"),
						x="STAR Gap from Grade Level in Years (negative is below)",
						y="Percent of Students"
			)+
			theme(title=element_text(size=6),
						axis.text.y=element_text(size=6),
						axis.text.x=element_text(size=6)
			)+
			facet_grid(subject.y + grade.y ~ subject.x)
	}
	if(nrow(d.star)>0){
		stars <- star.plot(d.star, star.means)
	}else{
		stars <- grob()
	}
	
  # Observation scores plot
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

plot.teacher.summary.mockup <- function(teacher.name, se.data, gsse.data, star.data,
																	highlights, star.means, obs.data, obs.means,
																	all.obs.means) {
	p <- teacher.summary.plot.38(teacher.name, se.data, gsse.data, star.data,
																	highlights, star.means, obs.data, obs.means,
																	all.obs.means)
	pdf(paste0("../output/teacher profiles/", teacher.name, " Profile 2013-14.pdf"), width=10.5, height=7)
	print(p)
	dev.off()
}