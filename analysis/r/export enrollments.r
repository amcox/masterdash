update_functions <- function() {
	old.wd <- getwd()
	setwd("functions")
	sapply(list.files(), source)
	setwd(old.wd)
}
update_functions()

con <- prepare_connection()

df <- get_enrollments_data(con)

save_df_as_csv(df, 'enrollments data')