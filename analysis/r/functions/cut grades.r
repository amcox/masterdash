cut_grade_categories <- function(vec) {
  cut(vec, c(-1, 2, 6, 9),
    labels=c("0_2", "3_5", "6_8"), right=FALSE
  )
}

