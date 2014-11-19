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

df.se <- get_scores_enrollments_data(con)
df.se$achievement_level <- make_adjusted_als(df.se$achievement_level)

ap <- df.se %>% group_by(teacher_number, teacher_name, school, test_name, subject) %>%
  summarize(
    n = n(),
    perc.u = mean(achievement_level == 'U'),
    perc.ab = mean(achievement_level == 'AB'),
    perc.b = mean(achievement_level == 'B'),
    perc.m = mean(achievement_level == 'M'),
    perc.a = mean(achievement_level == 'A'),
    perc.cr = mean(achievement_level %in% c('A', 'M', 'B')),
    ai = mean(ai_points, na.rm=T)
  )

# Percent CR correlation with B3 only
d <- ap %>%
  select(teacher_number, teacher_name, school, test_name, subject, perc.cr) %>%
  subset(test_name %in% c('B3', 'L14')) %>%
  spread(test_name, perc.cr)

ggplot(d, aes(x=B3, y=L14))+
  geom_point()+
  geom_smooth(method='lm')+
  scale_x_continuous(labels=percent, limits=c(0,1))+
  scale_y_continuous(labels=percent, limits=c(0,1))+
  labs(title='Percent Basic and Above on Benchmark 3 and LEAP, 2013-14')+
  theme_bw()+
  facet_wrap(~subject)
  
models <- d %>% group_by(subject) %>% do(model = lm(L14 ~ B3, data = .))
models %>% mutate(rsq = summary(model)$r.squared)

# TODO: AI correlation, average of benchmarks