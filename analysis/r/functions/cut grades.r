cut_grade_categories <- function(vec) {
  cut(vec, c(-2, 2, 6, 9),
    labels=c("PK_2", "3_5", "6_8"), right=FALSE
  )
}

