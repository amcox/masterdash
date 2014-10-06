make_small_school_labels <- function(d) {
  apply(d, 1, function(r){
  	paste0(r['school'], r['grade.category'])
  })
}

make_small_school <- function(r, grade.col='grade') {
  if(r['school'] == 'SCH'){
    gc <- cut(as.numeric(r[grade.col]), c(-5, 4, 7, 9),
      labels=c("PK-3", "4-6", "7-8"), right=FALSE
    )
  }else{
    gc <- cut(as.numeric(r[grade.col]), c(-5, 3, 6, 9),
      labels=c("PK-2", "3-5", "6-8"), right=FALSE
    )
  }
  return(paste(r['school'], gc, sep=' '))
}