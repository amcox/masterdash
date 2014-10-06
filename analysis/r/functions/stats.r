make_nce_from_percentile <- function(percentile.vec) {
  qnorm(percentile.vec/100)*21.06 + 50
}

find.mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

neg_safe_percent <- function (x) {
    x <- round_any(x, .01)
    paste0(comma(x * 100), "%")
}


suffixPicker <- function(x) {
    suffix <- c("st", "nd", "rd", rep("th", 17))
    suffix[((x-1) %% 10 + 1) + 10*(((x %% 100) %/% 10) == 1)]
}

ordinalized <- function(x) {
  paste0(x, suffixPicker(x))
}

percentile_format <- function(x) {
  ordinalized(round_any(x, .01) * 100)
}