library(plyr)
library(dplyr)
library(gdata)
library(reshape2)
library(ggplot2)
library(scales)
library(gridExtra)
library(stringr)

update_functions <- function() {
	old.wd <- getwd()
	setwd("functions")
	sapply(list.files(), source)
	setwd(old.wd)
}
update_functions()

con <- prepare_connection()

# Get LEAP data
df <- get_single_score_per_student_with_student_data(con)
df <- subset(df, test_name == 'L14' & achievement_level %in% leap.als)
df <- df[, c('subject', 'achievement_level', 'grade', 'school', 'student_number')]

# Get report card data
d.rc <- load_report_card_data()
d.rc <- d.rc[, c('Marking.Period', 'External.ID', 'Course.Grade', 'Course.Name', 'Original.Score')]
names(d.rc) <- c('marking.period', 'student_number', 'course.grade', 'subject', 'score')
d.rc <- subset(d.rc, subject %in% c('ELA', 'Math', 'Science', 'Social Studies'))
d.rc$subject <- str_replace_all(d.rc$subject, 'ELA', 'ela')
d.rc$subject <- str_replace_all(d.rc$subject, 'Math', 'math')
d.rc$subject <- str_replace_all(d.rc$subject, 'Science', 'sci')
d.rc$subject <- str_replace_all(d.rc$subject, 'Social Studies', 'soc')
d.rc <- d.rc %>% group_by(marking.period, student_number, subject) %>% summarize(score=mean(score, na.rm=T))

d.c <- merge(df, d.rc)
d.c$grade.category <- cut_grade_categories(d.c$grade)

make_al_dist_plot <- function(d, marking.period.name, more.title=NULL) {
  ggplot(d, aes(x=h.mids, y=h.counts, color=achievement_level))+
    geom_line()+
    scale_x_continuous(breaks=seq(0, 100, 10))+
    scale_color_discrete(name="L14 AL")+
    labs(x=paste0('Percent Grade in ', marking.period.name),
      y='Number of Students',
      title=paste0("Achievement Levels of Students According to ", marking.period.name, " Grades", more.title)
    )+
    theme_bw()
}

# Run graphs for just Q4
d.3 <- subset(d.c, marking.period == 'Q3' & !is.na(score))
dc <- d.3 %>% group_by(achievement_level, grade.category, school) %>% do(get_counts(., 'score', seq(0,100,5)))
dc$achievement_level <- reorder.factor(dc$achievement_level, new.order=leap.als)
p <- make_al_dist_plot(dc, "Q3") + facet_grid(grade.category~school) + theme(axis.text.x=element_text(size=6))
save_plot_as_pdf(p, 'LEAP and Q4 Grades Comparison, by Small School')

# Curves of percent at or above that level
calc_perc_above <- function(d){
	find_perc_above <- function(cut.percent, data){
    v <- data$score
    v <- v[!is.na(v)]
    length(v[v >= cut.percent]) / length(v)
	}
	scores <- unique(d$score)
	just.percs <- sapply(scores, find_perc_above, data=d)
	new.df <- data.frame(score=scores, percent.at.or.above=just.percs)
	return(new.df)
}

threshes <- d.3 %>% group_by(subject) %>% do(calc_perc_above(.))
actual.perc.cr <- data.frame(subject=c('ela', 'math', 'sci', 'soc'), percent.cr=c(.48, .57, .47, .52))
p <- ggplot(threshes, aes(x=score, y=percent.at.or.above))+
	geom_hline(data=actual.perc.cr, aes(yintercept=percent.cr), type=2, show_guide=F)+
  geom_point()+
  scale_y_continuous(breaks=seq(0,1,.05), label=percent)+
  scale_x_continuous(breaks=seq(0,100,10))+
	labs(title='Proportion of Students Scoring at or Above Each Percent in Q3 Grades',
				x="Q3 Grade",
				y="Percent of Students at or Above that Score"
	)+
	theme_bw()+
  facet_wrap(~subject)
  
save_plot_as_pdf(p, 'Percent of Students Earning at or Above Each Grade, Q3')

# Find the accuracy rate of Q3 grades prediciton proficiency on LEAP
find_grade_leap_estimate_status <- function(r, cut.score) {
  s <- r['score']
  al <- r['achievement_level']
  if(is.na(s)){
    return(NA)
  }
  s.status <- as.numeric(s) >= cut.score
  al.status <- al %in% c('B', 'M', 'A')
 if(s.status & al.status){
   return('match')
 }else if(!s.status & !al.status){
   return('match')
 }else if(s.status & !al.status){
   return('over.estimate')
 }else if(!s.status & al.status){
   return('under.estimate')
 }
}

c <- d.3 %>% group_by(subject) %>% do(make_match_percs(., seq(0, 100, 1), find_grade_leap_estimate_status))
p <- ggplot(c, aes(x=cut, y=match.perc, color=subject))+
  geom_line()+
  scale_y_continuous(limits=c(0,1), breaks=seq(0,1,.1), label=percent)+
  scale_x_continuous(limits=c(0,100), breaks=seq(0,100,5))+
  labs(title='LEAP Prediction Accuracy by Q3 Grade Cut Score',
    x="Cut Grade Percent",
    y='Percent of Predictions that are Accurate'
  )+
  theme_bw()
save_plot_as_pdf(p, 'Match Percents for Quarter 3 by Subject')

d.3$small.school <- paste(d.3$school, d.3$grade.category, sep='.')
c <- d.3 %>% group_by(small.school) %>% do(make_match_percs(., seq(0, 100, 1), find_grade_leap_estimate_status))
p <- ggplot(c, aes(x=cut, y=match.perc, color=small.school))+
  geom_line(alpha=.8)+
  scale_y_continuous(limits=c(0,1), breaks=seq(0,1,.1), label=percent)+
  scale_x_continuous(limits=c(0,100), breaks=seq(0,100,5))+
  labs(title='LEAP Prediction Accuracy by Q3 Grade Cut Score',
    x="Cut Grade Percent",
    y='Percent of Predictions that are Accurate'
  )+
  theme_bw()
save_plot_as_pdf(p, 'Match Percents for Quarter 3 by School')

c <- d.3 %>% do(make_match_percs(., seq(0, 100, 1), find_grade_leap_estimate_status))
c <- melt(c, id.vars=c('cut'))
p <- ggplot(c, aes(x=cut, y=value, color=variable))+
  geom_line()+
  scale_y_continuous(limits=c(0,1), breaks=seq(0,1,.1), label=percent)+
  scale_x_continuous(limits=c(0,100), breaks=seq(0,100,5))+
  scale_color_discrete(labels=c('match.perc'='Accurate', 'under.perc'='Under-Predicted', 'over.perc'='Over-Predicted'))+
  labs(title='LEAP Prediction Accuracy by Q3 Grade Cut Score',
    x="Cut Grade Percent",
    y='Percent of Predictions'
  )+
  theme_bw()+
  theme(legend.title=element_blank())
save_plot_as_pdf(p, 'Prediction Percents for Quarter 3')