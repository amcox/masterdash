library(dplyr)
library(gdata)
library(reshape2)
library(tidyr)

update_functions <- function() {
	old.wd <- getwd()
	setwd("functions")
	sapply(list.files(), source)
	setwd(old.wd)
}
update_functions()

con <- prepare_connection(aws=T)

d <- get_single_score_per_student_with_student_data(con)

# Just including achievement_level
ds <- subset(d, !is.na(achievement_level)) %>%
	select(student_number, grade, school, test_order, test_name, subject, achievement_level) %>%
	mutate(test = paste0(subject, '.', test_name)) %>%
	arrange(school, grade, student_number, subject, test_order)
	
dw <- ds %>% spread(test, achievement_level)

# Both achievement level and numeric score, NOT WORKING YET
ds <- subset(d, !is.na(achievement_level)) %>%
	select(student_number, grade, school, test_order, test_name, subject, achievement_level, percent, scaled_score) %>%
	mutate(test = paste0(subject, '.', test_name), numeric = max(percent, scaled_score, na.rm=T))
	arrange(school, grade, student_number, subject, test_order) %>%
	
dw <- ds %>% spread(test, achievement_level)

# Still don't have student names, just IDs, need to add that next