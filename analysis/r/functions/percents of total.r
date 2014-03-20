percents_of_total <- function(vec, col.name) {
    n = length(vec)
    out <- data.frame(vec,1) %.%
      group_by(vec) %.%
      dplyr::summarise(
        perc = length(X1)/n
      )
    names(out) <- c(col.name, "perc")
    return(out)
}

percents_of_total_als <- function(vec, col.name) {
    n = length(vec)
    out <- data.frame(vec,1) %.%
      group_by(vec) %.%
      dplyr::summarise(
        perc = length(X1)/n
      )
    names(out) <- c(col.name, "perc")
    als <- data.frame(als=c("A", "M", "B", "AB", "U"))
    names(als) <- col.name
    out <- merge(out, als, all=T)
    out[is.na(out)] <- 0
    return(out)
}