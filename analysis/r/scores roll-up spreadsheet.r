library(dplyr)
library(dplyr)
library(gdata)
library(reshape2)

update_functions <- function() {
	old.wd <- getwd()
	setwd("functions")
	sapply(list.files(), source)
	setwd(old.wd)
}
update_functions()

con <- prepare_connection()
df <- create_student_school_scores_roll_up(con)

d.w <- dcast(df, ... ~ achievement.level)
d.w$cr <- apply(d.w, 1, function(r) {
  if(r['grade'] %in% c('0', '1', '2', '0_2')){
    as.numeric(r['A']) + as.numeric(r['M'])
  }else{
    as.numeric(r['A']) + as.numeric(r['M']) + as.numeric(r['B'])   
  }
})

save_df_as_csv(d.w, "Scores Roll-Up 2014-15")