# Generate teacher profile PDFs for each teacher
library(plyr)
library(dplyr)
library(gdata)
library(reshape2)
library(ggplot2)
library(scales)
library(gridExtra)
library(tidyr)

update_functions <- function() {
	old.wd <- getwd()
	setwd("functions")
	sapply(list.files(), source)
	setwd(old.wd)
}
update_functions()

con <- prepare_connection()

teacher_plot_table_theme <- function(...) {
  modifyList(
    theme.default(show.rownames = FALSE, show.colnames = TRUE, 
      row.just = "center", col.just = "center", core.just = "center", 
      separator = "white", show.box = FALSE, show.csep = FALSE, 
      show.rsep = FALSE, equal.width = FALSE, equal.height = FALSE, 
      padding.h = unit(4, "mm"), padding.v = unit(4, "mm"),
      gpar.coretext = gpar(col = "black", cex = 1),
      gpar.coltext = gpar(col = "black", cex = 1, fontface = "bold"),
      gpar.rowtext = gpar(col = "black", cex = 0.8, fontface = "italic"),
      h.odd.alpha = 0.5, h.even.alpha = 0, v.odd.alpha = 1,
      v.even.alpha = 1, gpar.corefill = gpar(fill = "grey90", col = NA),
      gpar.rowfill = gpar(fill = "grey90", col = NA), 
      gpar.colfill = gpar(fill = "grey90", col = NA), gp=gpar(fontsize=9)
    ), list(...)
  )
}

## ALs
  make_teacher_al_table_48 <- function(teacher.name, all.teachers.info) {
    t.al.info <- subset(all.teachers.info, teacher_name == teacher.name)
    teacher.table <- data.frame(labs=c('Students College-Ready on B1', 'Growth in Students College Ready from LEAP'),
      percs=c(neg_safe_percent(t.al.info$B1), neg_safe_percent(t.al.info$l.to.b1)),
      perciles=c(percentile_format(t.al.info$B1.percile), percentile_format(t.al.info$l.to.b1.percile))
    )
    al.table <- tableGrob(teacher.table,
      show.rownames=F,
      show.colnames=F,
      cols=c('ReNEW Benchmarks', '', 'Percentile Rank\n4th - 8th Teachers'),
      theme=teacher_plot_table_theme()
    )
    return(al.table)
  }
  
  make_teacher_al_table_3 <- function(teacher.name, all.teachers.info) {
    t.al.info <- subset(all.teachers.info, teacher_name == teacher.name)
    teacher.table <- data.frame(labs=c('Students College-Ready on B1'),
      percs=c(neg_safe_percent(t.al.info$B1)),
      perciles=c(percentile_format(t.al.info$B1.percile))
    )
    al.table <- tableGrob(teacher.table,
      show.rownames=F,
      show.colnames=F,
      cols=c('ReNEW Benchmarks', '', 'Percentile Rank\n3rd Teachers'),
      theme=teacher_plot_table_theme()
    )
    return(al.table)
  }
  
  make_teacher_al_plot_38 <- function(teacher.name, df.se, highlights) {
    
    make_al_table <- function(d) {
      data.frame(prop.table(table(d$test_name, d$achievement_level), 1))
    }
    
    se.t <- subset(df.se, teacher_name == teacher.name) %>%
      select(id, teacher_name, achievement_level, test_name)
  
    d.props <- se.t %>% do(make_al_table(.)) %>% data.frame()
    names(d.props) <- c("test", "achievement_level", "perc")
    d.props$achievement_level <- gdata:::reorder.factor(d.props$achievement_level,
    															new.order=c("A", "M", "B", "AB", "U")
    )
    d.props <- d.props[order(as.numeric(d.props$achievement_level)),]

    # b.above <- subset(d.props, achievement_level %in% c("A", "M", "B"))
    # b.above <- b.above %>% group_by(test) %>% summarize(perc=sum(perc))
    
    b.above <- se.t %>% group_by(test_name) %>% summarize(perc=mean(achievement_level %in% c('A', 'M', 'B')))
    
    p.bars <- ggplot()+
    	geom_bar(data=subset(d.props, achievement_level != 'U'), aes(x=test, y=perc, fill=achievement_level), stat="identity")+
    	geom_bar(data=highlights, aes(x=test, y=perc), fill="white", stat="identity", alpha=.4)+
    	scale_x_discrete(limits=test.order)+
    	scale_y_continuous(labels=percent, breaks=seq(0,1,.1))+
    	scale_fill_manual(values=alPalette.light.lows, guide=F)+
    	ylab("Percent of Scores")+
    	xlab("Assessment")+
    	labs(title="Percent of Scores at Achievement Levels, All Subjects and Grades")+
    	theme_bw()+
    	theme(axis.text.x=element_text(size=6, angle=90, vjust=0.5),
    				axis.text.y=element_text(size=6),
    				title=element_text(size=7)
    	)

    b.above.l14 <- subset(b.above, test_name=="L14")
    if(nrow(b.above.l14) > 0){
    	p.bars  <- p.bars + geom_hline(data=b.above.l14,
        aes(yintercept=perc+.1), linetype=3
    	)
    }
    return(p.bars)
  }
  
  make_teacher_obs_table <- function(teacher.name, t.means) {
    obs.t <- subset(t.means, name == teacher.name & quarter == 1)
    teacher.table <- data.frame(labs=c('Score on Q1 Observations'),
      percs=c(obs.t$score
      ),
      perciles=c(percentile_format(obs.t$q.percile)
      )
    )
    obs.table <- tableGrob(teacher.table,
      show.rownames=F,
      show.colnames=F,
      cols=c('AIM Rubric Observations', '', 'Percentile Rank\nAll Teachers'),
      theme=teacher_plot_table_theme()
    )
    return(obs.table)
  }
  
  make_teacher_obs_plot <- function(teacher.name, t.means, all.stats) {
    d.obs <- subset(t.means, name==teacher.name)
    if(nrow(d.obs) > 0){
    	p.obs <- ggplot()+
    		geom_crossbar(data=all.stats, aes(x=quarter, ymin=lowth, y=median, ymax=highth), fatten=1, color='#1B9E77')+
    		geom_point(data=d.obs, aes(x=quarter, y=score), shape=18, size=4, color="red")+
    		scale_y_continuous(limits=c(1,4), breaks=seq(1,4,0.5))+
        scale_x_discrete(limits=c(1, 2, 3, 4))+
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
    return(p.obs)
  }
  
  find_boxplot_iles <- function(d) {
    data.frame(
      lowth=boxplot.stats(d$score)$stats[2],
      median=boxplot.stats(d$score)$stats[3],
      highth=boxplot.stats(d$score)$stats[4],
      mean=mean(d$score, na.rm=T)
    )
  }
  
  make_teacher_info_set <- function(teacher.name, teacher.school) {
    t.school <- textGrob(teacher.school, gp=gpar(fontsize=12), hjust=1)
    t.name <- textGrob(teacher.name, gp=gpar(fontsize=12), hjust=0)
    g.names <- arrangeGrob(t.school, t.name, nrow=1)
    return(g.names)
  }
  
  make_plot_for_teacher <- function(teacher.name, teacher.school, t.means, all.stats, output.dir, al.set) {
    if(nrow(subset(t.means, name == teacher.name)) > 0){
      obs.table <- make_teacher_obs_table(teacher.name, t.means)
      obs.plot <- make_teacher_obs_plot(teacher.name, t.means, all.stats)
      obs.set <- arrangeGrob(obs.table, obs.plot, ncol=2)
    }else{
      obs.set <- grob()
    }

    info.set <- make_teacher_info_set(teacher.name, teacher.school)
  
    g.content <- arrangeGrob(al.set, obs.set, ncol=1)
  
    p <- arrangeGrob(info.set, g.content, ncol=1, heights=c(.1, .9),
      main=textGrob('\nReNEW Teacher Performance Dashboard 2014-15', gp=gpar(fontsize=18))
    )
    save_plot_as_pdf(p, paste0('/new teacher profiles/', output.dir, '/', teacher.name))
  }
  
  make_plot_for_teacher_48 <- function(teacher.name, teacher.school, apw, df.se, highlights, t.means, all.stats, output.dir) {
    al.table <- make_teacher_al_table_48(teacher.name, apw)
    al.plot <- make_teacher_al_plot_38(teacher.name, df.se, highlights)
    al.set <- arrangeGrob(al.table, al.plot, ncol=2)
    
    make_plot_for_teacher(teacher.name, teacher.school, t.means, all.stats, output.dir, al.set)
  }
  
  make_plot_for_teacher_3 <- function(teacher.name, teacher.school, apw, df.se, highlights, t.means, all.stats, output.dir) {
    al.table <- make_teacher_al_table_3(teacher.name, apw)
    al.plot <- make_teacher_al_plot_38(teacher.name, df.se, highlights)
    al.set <- arrangeGrob(al.table, al.plot, ncol=2)
    
    make_plot_for_teacher(teacher.name, teacher.school, t.means, all.stats, output.dir, al.set)
  }
  
  run_plots_for_small_school <- function(ss, ts.with.ss, plot.fun, apw, df.se, highlights, t.heans, all.stats, output.dir) {
    ss.ts <- subset(ts.with.ss, small.school == ss)
    teachers <- unique(ss.ts$teacher_name)
    lapply(teachers, plot.fun, teacher.school=ss, apw=apw, df.se=df.se,
      highlights=highlights, t.means=t.means, all.stats=all.stats, output.dir=ss
    )
  }
  
  
  # Observation data
  df.obs <- get_observation_data(con)
  df.obs$quarter <- factor(df.obs$quarter)

  t.means <- df.obs %>% group_by(name, quarter) %>%
    summarize(score=mean(score, na.rm=T))
  t.means$q.percile <- ecdf(t.means$score)(t.means$score)
  
  t.means.overall <- t.means %>% group_by(name) %>% summarize(score=mean(score))
  t.means.overall$percile <- ecdf(t.means.overall$score)(t.means.overall$score)
    
  all.stats <- t.means %>%
    group_by(quarter) %>%
    do(find_boxplot_iles(.))
  
  # AL data
  df.se <- get_scores_enrollments_data(con)
  df.se$achievement_level <- make_adjusted_als(df.se$achievement_level)
  
  # 4-8 roll-up data
  df.se.48 <- subset(df.se, grade > 3)
  ap <- df.se.48 %>% group_by(teacher_name, test_name) %>% summarize(perc.b = mean(achievement_level %in% c('A', 'M', 'B')))
  apw <- spread(ap, test_name, perc.b)
  apw <- apw %>% mutate(l.to.b1 = B1 - L14)
  apw$l.to.b1.percile <- ecdf(apw$l.to.b1)(apw$l.to.b1)
  apw$B1.percile <- ecdf(apw$B1)(apw$B1)
  apw.48 <- apw
  
  # 3 roll-up data
  df.se.3 <- subset(df.se, grade == 3)
  ap <- df.se.3 %>% group_by(teacher_name, test_name) %>% summarize(perc.b = mean(achievement_level %in% c('A', 'M', 'B')))
  apw <- spread(ap, test_name, perc.b)
  apw$B1.percile <- ecdf(apw$B1)(apw$B1)
  apw.3 <- apw


# Plot 4-8
teachers <- unique(df.se.48$teacher_name)
teacher.small.schools <- df.se.48 %>% group_by(teacher_name, school) %>% summarize(grade = max(grade))
teacher.small.schools$small.school <- apply(teacher.small.schools, 1, make_small_school)
small.schools <- unique(teacher.small.schools$small.school)
lapply(small.schools, run_plots_for_small_school, teacher.small.schools, make_plot_for_teacher_48, apw.48, df.se.48, highlights, t.heans, all.stats, output.dir)

# Plot 3
teachers <- unique(df.se.3$teacher_name)
teacher.small.schools <- df.se.3 %>% group_by(teacher_name, school) %>% summarize(grade = max(grade))
teacher.small.schools$small.school <- apply(teacher.small.schools, 1, make_small_school)
small.schools <- unique(teacher.small.schools$small.school)
lapply(small.schools, run_plots_for_small_school, teacher.small.schools, make_plot_for_teacher_3, apw.3, df.se.3, highlights, t.heans, all.stats, output.dir)


