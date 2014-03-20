library(plyr)

achievement_level_percents_long <- function(d, id.cols, al.col) {
  d.counts <- ddply(d, id.cols, summarize, count=length(al.col))
  d.counts.r <- dcast(d.counts, school + grade.category + subject + test_name +
  										sped_category ~ adj_achievement_level
  )
  d.counts.r[is.na(d.counts.r)] <- 0
  df <- cbind(d.counts.r[, 1:5], prop.table(as.matrix(d.counts.r[, 6:10]), 1))
  df.m<- melt(df, id.vars=c("school", "grade.category", "subject", "test_name",
  											"sped_category"),
  											variable.name="achievement_level",
  											value.name="perc"
  )
}