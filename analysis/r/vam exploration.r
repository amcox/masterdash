library(dplyr)
library(dplyr)
library(gdata)
library(tidyr)
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

dv <- load_student_vam_data()

de <- get_enrollments_data(con)
de <- unique(select(de, student_number, grade, school))

d <- merge(dv, de, by.x='student.id', by.y='student_number')


# Make scatterplots that show actual v target for large groups
make_vam_scatterplot <- function(d, title) {
  ggplot(subset(d, grade != 3), aes(x=target, y=actual))+
    geom_point(alpha=.2)+
    geom_smooth(fill=NA)+
    geom_abline(intercept=0, slope=1, color='#00C71E')+
    theme_bw()+
    labs(x='VAM Target Scaled Score',
      y='Actual Scaled Score',
      title=title
    )+
    theme(
      axis.text=element_text(size=7)
    )
}
p <- make_vam_scatterplot(d, 'Student Level VAM Results by Subject-School-Grade, 2013-14')+
  facet_grid(school ~ subject + grade)
save_plot_as_pdf(p, 'Student Level VAM Results by Subject-School-Grade, 2013-14')
  
p <- make_vam_scatterplot(d, 'Student Level VAM Results by Subject-School, 2013-14')+
  facet_grid(subject ~ school)
save_plot_as_pdf(p, 'Student Level VAM Results by Subject-School, 2013-14')

p <- make_vam_scatterplot(d, 'Student Level VAM Results by Subject, 2013-14')+
  facet_grid(~subject)
save_plot_as_pdf(p, 'Student Level VAM Results by Subject, 2013-14')

# VAM performance vs STAR growth
ds <- load_star_data()
ds <- select(ds, subject, StudentId:test.distance)
ds$subject[ds$subject == 'reading'] <- 'ela'
df.s <- merge(d, ds, by.x=c('student.id', 'subject'), by.y=c('StudentId', 'subject'))

p <- ggplot(subset(df.s, n > 3 & range < 6 & abs(modeled.year.growth) < 5 & grade > 3), aes(y=actual-target, x=modeled.year.gap.growth))+
  geom_point(alpha=.2)+
  geom_smooth()+
  labs(x='Modeled Year Gap Growth (Negative is Good)',
    y='Difference Between VAM Actual and Target (Positive is Good)',
    title='Student VAM Scores and STAR Growth'
  )+
  theme_bw()+
  facet_grid(subject~grade)
save_plot_as_pdf(p, 'Student VAM Scores and STAR Growth, By Grade')

p <- ggplot(subset(df.s, n > 3 & range < 6 & abs(modeled.year.growth) < 5 & grade > 3), aes(y=actual-target, x=modeled.year.gap.growth))+
  geom_point(alpha=.2)+
  geom_smooth()+
  labs(x='Modeled Year Gap Growth (Negative is Good)',
    y='Difference Between VAM Actual and Target (Positive is Good)',
    title='Student VAM Scores and STAR Growth'
  )+
  theme_bw()+
  facet_grid(~subject)
save_plot_as_pdf(p, 'Student VAM Scores and STAR Growth')

# VAM vs Grades
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

dg <- merge(d.c, select(d, student.id:subject), by.x=c('student_number', 'subject'), by.y=c('student.id', 'subject'))

p <- ggplot(subset(dg, marking.period == 'Q3'), aes(x=score, y=actual-target))+
  geom_point(alpha=.2)+
  geom_smooth()+
  theme_bw()+
  labs(x='Quarter 3 Percent Grade',
    y='Difference Between VAM Actual and Target (Positive is Good)',
    title='Student VAM Scores and Gradebook Grades'
  )+
  facet_grid(~subject)
save_plot_as_pdf(p, 'Student VAM Scored and Grades, Q3')

p <- ggplot(subset(dg), aes(x=score, y=actual-target))+
  geom_point(alpha=.2)+
  geom_smooth()+
  theme_bw()+
  labs(x='Percent Grade',
    y='Difference Between VAM Actual and Target (Positive is Good)',
    title='Student VAM Scores and Gradebook Grades'
  )+
  facet_grid(subject~marking.period)
save_plot_as_pdf(p, 'Student VAM Scored and Grades, By Quarter')


# Student VAM vs Benchmark Scores
df <- get_single_score_per_student_with_student_data(con)
db <- merge(df, select(d, student.id:subject), by.x=c('student_number', 'subject'), by.y=c('student.id', 'subject'))

p <- ggplot(subset(db, test_name == 'B3'), aes(x=percent, y=actual-target))+
  geom_point(alpha=.3)+
  geom_smooth()+
  theme_bw()+
  scale_x_continuous(labels=percent)+
  labs(x='Percent Correct',
    y='Difference Between VAM Actual and Target (Positive is Good)',
    title='Student VAM and Benchmark 3 Scores'
  )+
  facet_grid(~subject)
save_plot_as_pdf(p, 'Student VAM Scores and Benchmark 3')

# TODO: Make a model with benchmark, STAR, grades, school to predict VAM score and see what happens