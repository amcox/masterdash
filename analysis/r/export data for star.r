update_functions <- function() {
	old.wd <- getwd()
	setwd("functions")
	sapply(list.files(), source)
	setwd(old.wd)
}
update_functions()

con <- prepare_connection()

df <- get_single_score_per_student_with_student_data(con)

save_df_as_csv(df, 'scores data')