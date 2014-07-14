library(plyr)
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

make_score_matches <- function(d, id.vars=c('student_number', "school", "grade", "subject", 'achievement_level')) {
  firsts <- subset(d, test_name == 'L13')[, id.vars]
  # Rename the last column as 'first_al'
  names(firsts)[names(firsts)==names(firsts)[length(names(firsts))]] <- 'first_al'
  seconds <- subset(d, test_name == 'L14')[, id.vars]
  # Rename the last column as 'second_al'
  names(seconds)[names(seconds)==names(seconds)[length(names(seconds))]] <- 'second_al'
  b <- merge(firsts, seconds)
  return(b)
}

con <- check_for_con_and_create()
df <- get_single_score_per_student_with_student_data(con)

# Run for i/LEAP
df.leap <- drop.levels(subset(df, achievement_level %in% leap.als))
d.matches <- make_score_matches(df.leap)
d <- ddply(d.matches, .(school, grade, subject), function(d){movement_counts(d$first_al, d$second_al)})
d <- drop.levels(d)
d$first <- reorder(d$first, new.order=leap.als)
d$second <- reorder(d$second, new.order=leap.als)

for(s in plain.schools){
  for(g in 4:8){
    d.s <- subset(d, grade == g & school == s)
    p <- movement_plot(d.s, paste0(s, " ", long_labeller("grade", g)), 'LEAP 2013', "LEAP 2014", 3)+
      facet_wrap(~subject, ncol=2)
    save_plot_as_pdf(p, paste0(s, " ", long_labeller("grade", g), " LEAP Movement Grid"))
  }
}

# Run for LAA2
df.laa2 <- drop.levels(subset(df, achievement_level %in% laa2.als))
d.matches <- make_score_matches(df.laa2)
d.matches$grade <- cut_grade_categories(d.matches$grade)
d.matches <- drop.levels(d.matches)
d <- ddply(d.matches, .(school, grade, subject), function(d){movement_counts(d$first_al, d$second_al, al.nums=laa2.al.nums)})
d <- drop.levels(d)
d$first <- reorder(d$first, new.order=laa2.als)
d$second <- reorder(d$second, new.order=laa2.als)
for(s in plain.schools){
  for(g in c("3-5", "6-8")){
    d.s <- subset(d, grade == g & school == s)
    p <- movement_plot(d.s, paste0(s, " ", long_labeller("grade", g)), 'LAA2 2013', "LAA2 2014", 3)+
      facet_wrap(~subject, ncol=2)
    save_plot_as_pdf(p, paste0(s, " ", long_labeller("grade", g), " LAA2 Movement Grid"))
  }
}
  # Run combined for network
  d <- ddply(d.matches, .(subject), function(d){movement_counts(d$first_al, d$second_al, al.nums=laa2.al.nums)})
  d <- drop.levels(d)
  d$first <- reorder(d$first, new.order=laa2.als)
  d$second <- reorder(d$second, new.order=laa2.als)
  p <- movement_plot(d, 'All Schools and Grades LAA2 2013', "LAA2 2013", "LAA2 2014", 3)+
    facet_wrap(~subject, ncol=2)
  save_plot_as_pdf(p, paste0("All Schools and Grades", " LAA2 Movement Grid"))

# Run for LAA1
df.laa1 <- drop.levels(subset(df, achievement_level %in% laa1.als))
d.matches <- make_score_matches(df.laa1)
d.matches$grade <- cut_grade_categories(d.matches$grade)
d.matches <- drop.levels(d.matches)
d <- ddply(d.matches, .(school, grade, subject), function(d){movement_counts(d$first_al, d$second_al, al.nums=laa1.al.nums)})
d <- drop.levels(d)
d$first <- reorder(d$first, new.order=laa1.als)
d$second <- reorder(d$second, new.order=laa1.als)

for(s in plain.schools){
  for(g in c("3-5", "6-8")){
    d.s <- subset(d, grade == g & school == s)
    if(nrow(d.s) > 0){
      p <- movement_plot(d.s, paste0(s, " ", long_labeller("grade", g)), 'LAA1 2013', "LAA1 2014", 3)+
        facet_wrap(~subject, ncol=2)
      save_plot_as_pdf(p, paste0(s, " ", long_labeller("grade", g), " LAA1 Movement Grid"))
    }
  }
}
  # Run combined for network
  d <- ddply(d.matches, .(subject), function(d){movement_counts(d$first_al, d$second_al, al.nums=laa1.al.nums)})
  d <- drop.levels(d)
  d$first <- reorder(d$first, new.order=laa1.als)
  d$second <- reorder(d$second, new.order=laa1.als)
  p <- movement_plot(d, 'All Schools and Grades LAA1 2013', "LAA1 2013", "LAA1 2014", 3)+
    facet_wrap(~subject, ncol=2)
  save_plot_as_pdf(p, paste0("All Schools and Grades", " LAA1 Movement Grid"))
  
# For SPED by sped_category
df.sped <- get_sped_scores_data(con)

df.leap <- drop.levels(subset(df.sped, achievement_level %in% leap.als))
d.matches <- make_score_matches(df.leap, id.vars=c('student_number', "school", "grade", "subject", 'sped_category', 'achievement_level'))
d.matches$grade <- cut_grade_categories(d.matches$grade)
d <- ddply(d.matches, .(school, grade, subject, sped_category), function(d){movement_counts(d$first_al, d$second_al)})
d <- drop.levels(d)
d$first <- reorder(d$first, new.order=leap.als)
d$second <- reorder(d$second, new.order=leap.als)

d <- subset(d, count > 0)

for(s in plain.schools){
  for(g in c("3-5", "6-8")){
    d.s <- subset(d, grade == g & school == s)
    p <- movement_plot(d.s, paste0(s, " ", long_labeller("grade", g)), 'LEAP 2013', "LEAP 2014", 3)+
      facet_grid(sped_category ~ subject)
    save_plot_as_pdf(p, paste0(s, " ", long_labeller("grade", g), " LEAP Movement Grid"))
  }
}
