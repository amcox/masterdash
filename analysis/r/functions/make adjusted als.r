make_adjusted_als <- function(vec) {
  # Takes a vector and replaces LAA ALs with LEAP points equivalent
  vec <- gsub("AB2", "B", vec)
  vec <- gsub("B2", "A", vec)
  vec <- gsub("PF", "U", vec)
  vec <- gsub("F", "AB", vec)
  vec <- gsub("ES", "A", vec)
  vec <- gsub("MS", "B", vec)
  vec <- gsub("WTS", "AB", vec)
  return(vec)
}