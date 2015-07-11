# Exports a file with all student scores, one row per student and
# each score (subject-test-score type) as a column.

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

# Create single column for subject-test and one for percent/scaled score.
ds <- subset(d, !is.na(achievement_level)) %>%
	select(student_number, student_name, grade, school, test_order, test_name, subject, achievement_level, percent, scaled_score, ai_points) %>%
	mutate(test = paste0(subject, '.', test_name), numeric = ifelse(is.na(percent), scaled_score, percent))
	
# Subset and spread for each type of score (achievement_level, numeric, ai)
ds.al <- ds %>% select(student_number, student_name, grade, school, test, achievement_level) %>%
	mutate(test = paste0(test, '.al')) %>%
	spread(test, achievement_level)

ds.num <- ds %>% select(student_number, student_name, grade, school, test, numeric) %>%
	mutate(test = paste0(test, '.num')) %>%
	spread(test, numeric)
	
ds.ai <- ds %>% select(student_number, student_name, grade, school, test, ai_points) %>%
	mutate(test = paste0(test, '.ai')) %>%
	spread(test, ai_points)

# Merge the separate score type spreads back together
dw <- merge(ds.al, ds.num, all.x=T)
dw <- merge(dw, ds.ai, all.x=T)

# Create the correct order for the columns
test.orders <- ds %>% select(test_name, test_order) %>% unique()
wide.cols <- dw %>% select(-student_number, -student_name, -grade, -school) %>%
	names() %>% data.frame(raw.name = ., stringsAsFactors=F) %>%
	mutate(original = raw.name) %>%
	separate(raw.name, c('subject', 'test_name', 'score.type')) %>%
	mutate(score.type = factor(score.type, levels = c('al', 'num', 'ai'))) %>%
	merge(test.orders) %>%
	arrange(subject, test_order, score.type)
	
# Select the data frame according to the correct order
dw.o <- dw %>% select_(.dots = c('student_number', 'student_name', 'grade', 'school', wide.cols$original))

save_df_as_csv(dw.o, 'all student scores, 2014-15')