test.order <- c("L13", "MLQ1", "MLQ2", "MLQ3", "B1", "MLQ4", "MLQ5", "B2", "MLQ6", "MLQ7", "B3", "L14", "B4")

alPalette <- c("A"="#00D77B", "M"="#00BE61", "B"="#198D33", "AB"="#E5E167", "U"="#D16262")
alPalette.light.lows <- c("A"="#00D77B", "M"="#00BE61", "B"="#198D33", "AB"="#E6E5CF", "U"="#D1BCBC")

achievement.levels.with.laa <- c("A", "M", "B", "AB", "U", "B2", "AB2", "F", "PF", "ES", "MS", "WTS")
al.order.low.high <- c("WTS", "MS", "ES", "PF", "F", "AB2", "B2", "U", "AB", "B", "M", "A")
leap.als <- c("U", "AB", "B", "M", "A")
laa2.als <- c("PF", "F", "AB2", "B2")
laa1.als <- c("WTS", "MS", "ES")
leap.al.nums <- list("A"=5, "M"=4, "B"=3, "AB"=2, "U"=1)
laa2.al.nums <- list("B2"=4, "AB2"=3, "F"=2, "PF"=1)
laa1.al.nums <- list("ES"=3, "MS"=2, "WTS"=1)

all.grades <- c(0, 1, 2, 3, 4, 5, 6, 7, 8, "0_2", "3_5", "6_8", "3_8", "0_8")
plain.grades <- c("0", "1", "2", "3", "4", "5", "6", "7", "8")
total.grades <- c("0_2", "3_5", "6_8", "3_8", "0_8")
cr.growth.grades <- c(3, 4, 5, 6, 7, 8, "3_5", "6_8", "3_8")
plain.grades.leap <- c("3", "4", "5", "6", "7", "8")

schools <- c("RCAA", "STA", "DTA", "SCH", "all")
plain.schools <- c("RCAA", "STA", "DTA", "SCH")

subjects.order <- c("ela", "math", "sci", "soc", "all")
plain.subjects <- c("ela", "math", "sci", "soc", "all")

# Make df to highlight benchmark and leap scores
highlights <- data.frame(test=c("MLQ1", "MLQ2", "MLQ3", "MLQ4", "MLQ5", "MLQ6", "MLQ7"),
                        perc=c(1,1,1,1,1,1,1)
)

al.numbers <- data.frame(achievement_level=c("A", "M", "B", "AB", "U", "B2", "AB2", "F", "PF", "ES", "MS", "WTS"),
												achievement_code=c(1, 0.75, 0.5, 0.25, 0, 1, 0.5, 0.25, 0, 1, 0.5, 1)
)