make_match_percs <- function(d, cuts, status.func) {
  out.frame <- data.frame(cut=cuts)
  out.frame$match.perc <- apply(out.frame, 1, function(r) {
    d$estimate.status <- apply(d, 1, status.func, as.numeric(r['cut']))
    props <- round(prop.table(table(d$estimate.status)),2)
    return(
      tryCatch(props[['match']], error = function(e){NA})
    )
  })
  out.frame$over.perc <- apply(out.frame, 1, function(r) {
    d$estimate.status <- apply(d, 1, status.func, as.numeric(r['cut']))
    props <- round(prop.table(table(d$estimate.status)),2)
    return(
      tryCatch(props[['over.estimate']], error = function(e){NA})
    )
  })
  out.frame$under.perc <- apply(out.frame, 1, function(r) {
    d$estimate.status <- apply(d, 1, status.func, as.numeric(r['cut']))
    props <- round(prop.table(table(d$estimate.status)),2)
    return(
      tryCatch(props[['under.estimate']], error = function(e){NA})
    )
  })
  return(out.frame)
}