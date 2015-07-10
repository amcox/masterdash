library(dplyr)
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
save_df_as_csv(ap, '2014-15 state test and local benchmark scores by teacher')