make_small_school_labels <- function(d) {
  apply(d, 1, function(r){
  	paste0(r['school'], r['grade.category'])
  })
}

