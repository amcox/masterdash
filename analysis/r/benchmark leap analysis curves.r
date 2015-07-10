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

df <- get_single_score_per_student_with_student_data(con)

get_matched_bench_leap_scores <- function(d, bench.name) {
  d.b <- subset(df, test_name == bench.name)
  d.l14 <- subset(df, test_name == 'L14' & achievement_level %in% leap.als)

  d.bs <- d.b[, c("student_id", "subject", "achievement_level", "percent", "grade", "school")]
  names(d.bs)[names(d.bs) == 'achievement_level'] <- 'b.al'
  names(d.bs)[names(d.bs) == 'percent'] <- 'b.percent'
  d.l14s <- d.l14[, c("student_id", "subject", "achievement_level", "scaled_score", "grade", "school")]
  names(d.l14s)[names(d.l14s) == 'achievement_level'] <- 'l14.al'
  names(d.l14s)[names(d.l14s) == 'scaled_score'] <- 'l14.scaled_score'

  dm <- merge(d.bs, d.l14s)
}

dm <- get_matched_bench_leap_scores(df, "B3")

# Find the percent of students scoring at or above that percent correct that scored Basic or above on the LEAP
calc_basic_threshes <- function(d){
	find_percent_basic <- function(cut.percent, data){
		mean(data[data$b.percent >= cut.percent,]$l14.al %in% c('B', 'M', 'A'), na.rm=TRUE)
	}
	b.percents <- unique(d$b.percent)
	just.percs <- sapply(b.percents, find_percent_basic, data=d)
	new.df <- data.frame(b.percent=b.percents, percent.basic=just.percs)
	return(new.df)
}

threshes <- dm %>% group_by(subject) %>% do(calc_basic_threshes(.))

p <- ggplot(threshes, aes(x=b.percent, y=percent.basic, color=subject))+
	geom_point()+
  scale_y_continuous(breaks=seq(0,1,.05), label=percent)+
  scale_x_continuous(breaks=seq(0,1,.1), label=percent)+
	labs(title="Proportions of Students Scoring Basic or Above by Percent Correct on Benchmark 3",
				x="Percent Correct on Benchmark",
				y="Percent of Students at or Above the Benchmark Score that Scored Basic or Above on LEAP"
	)+
	theme_bw()

save_plot_as_pdf(p, "Percent of Students Scoring Basic on LEAP by Percent Correct on Benchmark 3")

# Find the percent of scores at or above each score, for matching against percent Basic and above manualy
calc_perc_above <- function(d){
	find_perc_above <- function(cut.percent, data){
    v <- data$b.percent
    v <- v[!is.na(v)]
    length(v[v >= cut.percent]) / length(v)
	}
	b.percents <- unique(d$b.percent)
	just.percs <- sapply(b.percents, find_perc_above, data=d)
	new.df <- data.frame(b.percent=b.percents, percent.at.or.above=just.percs)
	return(new.df)
}

threshes <- dm %>% group_by(subject) %>% do(calc_perc_above(.))

calculated.perc.cr <- dm %>% group_by(subject) %>% summarize(percent.cr=mean(l14.al %in% c('B', 'M', 'A'), na.rm=T))
calculated.perc.cr$type <- rep('calculated', nrow(calculated.perc.cr))
actual.perc.cr <- data.frame(subject=c('ela', 'math', 'sci', 'soc'), percent.cr=c(.48, .57, .47, .52))
actual.perc.cr$type <- rep('actual', nrow(actual.perc.cr))
percs.cr <- rbind(calculated.perc.cr, actual.perc.cr)

p <- ggplot(threshes, aes(x=b.percent, y=percent.at.or.above))+
	geom_hline(data=percs.cr, aes(yintercept=percent.cr, color=type), type=2, show_guide=T)+
  geom_point()+
  scale_y_continuous(breaks=seq(0,1,.05), label=percent)+
  scale_x_continuous(breaks=seq(0,1,.1), label=percent)+
  scale_color_manual(name='% of Students\nScoring Basic and\nAbove on LEAP', values=c('blue', 'orange'))+
	labs(title='Proportion of Students Scoring at or Above Each Percent Correct on Benchmark 3',
				x="Percent Correct on Benchmark",
				y="Percent of Students at or Above that Score"
	)+
	theme_bw()+
  facet_wrap(~subject)

save_plot_as_pdf(p, "Percent of Students Scoring At or Above Each Benchmark Percent")

# Maximize the percent of students for predicitons matching actual
find_bench_leap_estimate_status <- function(r, cut.score) {
  s <- r['b.percent']
  al <- r['l14.al']
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
c <- dm %>% group_by(subject) %>% do(make_match_percs(., seq(0, 1, .01), find_bench_leap_estimate_status))

p <- ggplot(c, aes(x=cut, y=match.perc, color=subject))+
  geom_line()+
  scale_y_continuous(limits=c(0,1), breaks=seq(0,1,.1), label=percent)+
  scale_x_continuous(limits=c(0,1), breaks=seq(0,1,.05), label=percent)+
  labs(title='LEAP Prediction Accuracy by Cut Score on Benchmark 3',
    x="Cut Score",
    y='Percent of Predictions that are Accurate'
  )+
  theme_bw()
save_plot_as_pdf(p, 'Match Percents for Benchmark 3 by Subject')

# Now just for students Basic or above on LEAP
c <- subset(dm, l14.al %in% c('B', 'M', 'A')) %>% group_by(subject) %>%
  do(make_match_percs(., seq(0, 1, .01), find_bench_leap_estimate_status))

p <- ggplot(c, aes(x=cut, y=match.perc, color=subject))+
  geom_line()+
  scale_y_continuous(limits=c(0,1), breaks=seq(0,1,.1), label=percent)+
  scale_x_continuous(limits=c(0,1), breaks=seq(0,1,.05), label=percent)+
  labs(title='LEAP Prediction Accuracy by Cut Score on Benchmark 3, Just Basic and Above on LEAP',
    x="Cut Score",
    y='Percent of Predictions that are Accurate'
  )+
  theme_bw()
save_plot_as_pdf(p, 'Match Percents for Benchmark 3 by Subject, Basic and Above on LEAP Only')

# Prediction curves
c <- dm %>% do(make_match_percs(., seq(0, 1, .01), find_bench_leap_estimate_status))
c <- melt(c, id.vars=c('cut'))
p <- ggplot(c, aes(x=cut, y=value, color=variable))+
  geom_line()+
  scale_y_continuous(limits=c(0,1), breaks=seq(0,1,.1), label=percent)+
  scale_x_continuous(limits=c(0,1), breaks=seq(0,1,.05), label=percent)+
  scale_color_discrete(labels=c('match.perc'='Accurate', 'under.perc'='Under-Predicted', 'over.perc'='Over-Predicted'))+
  labs(title='LEAP Prediction Accuracy by Benchmark 3 Cut Score',
    x="Cut Score",
    y='Percent of Predictions'
  )+
  theme_bw()+
  theme(legend.title=element_blank())
save_plot_as_pdf(p, 'Prediction Percents for Benchmark 3')

c <- dm %>% group_by(subject) %>% do(make_match_percs(., seq(0, 1, .01), find_bench_leap_estimate_status))
c <- melt(c, id.vars=c('cut', 'subject'))
p <- ggplot(c, aes(x=cut, y=value, color=variable))+
  geom_line()+
  scale_y_continuous(limits=c(0,1), breaks=seq(0,1,.1), label=percent)+
  scale_x_continuous(limits=c(0,1), breaks=seq(0,1,.1), label=percent)+
  scale_color_discrete(labels=c('match.perc'='Accurate', 'under.perc'='Under-Predicted', 'over.perc'='Over-Predicted'))+
  labs(title='LEAP Prediction Accuracy by Benchmark 3 Cut Score',
    x="Cut Score",
    y='Percent of Predictions'
  )+
  theme_bw()+
  theme(legend.title=element_blank(),
  axis.text.x=element_text(size=8)
  )+
  facet_wrap(~subject)
save_plot_as_pdf(p, 'Prediction Percents for Benchmark 3 by Subject')