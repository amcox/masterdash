##  make my data
Hospital <- c(rep("A", 20), rep("B", 20))
Ward <- rep(c(rep("ICU", 10), rep("Medicine", 10)), 2)
Month <- rep(seq(1:10), 4)
Outcomes <- rnorm(40, 20, 5)
df <- data.frame(Hospital, Ward, Month, Outcomes)

## knitr loop
library("knitr")
for (hosp in unique(df$Hospital)){
  knit2pdf("testingloops.Rnw", output=paste0('report_', hosp, '.tex'))
}

tools::texi2pdf('report_A.tex')