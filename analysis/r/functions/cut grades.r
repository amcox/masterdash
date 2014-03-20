cut_grade_categories <- function(vec) {
  cut(vec, c(-1, 2, 6, 9),
    labels=c("K2", "35", "68"), right=FALSE
  )
}

