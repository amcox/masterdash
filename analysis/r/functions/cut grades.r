cut_grade_categories <- function(vec) {
  cut(vec, c(-1, 2, 6, 9),
    labels=c("0-2", "3-5", "6-8"), right=FALSE
  )
}

