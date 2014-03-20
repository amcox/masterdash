turn_chars_to_factors <- function(d) {
  data.frame(rapply(d, as.factor, classes="character",
  											how="replace")
  )
}