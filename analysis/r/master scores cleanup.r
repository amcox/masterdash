library(gdata)
library(plyr)
library(reshape2)

test.order <- c("L13", "M1", "M2", "M3", "B1", "M4", "M5", "B2", "M6", "M7", "B3", "PL", "L14", "B4")
schools <- c("RCAA", "STA", "DTA", "SCH", "All")
grades.order <- c(0, 1, 2, 3, 4, 5, 6, 7, 8, "0_2", "3_5", "6_8", "3_8", "t")
achievement.levels <- c("unsat", "ab", "basic", "mast", "adv")
als <- c("U", "AB", "B", "M", "A")
plain.grades <- c("0", "1", "2", "3", "4", "5", "6", "7", "8")
total.grades <- c("0_2", "3_5", "6_8", "3_8", "t")
subjects <- c("ela", "math", "sci", "ss", "t")


df <- read.csv(file="../../csvs/master raw.csv", head=TRUE, sep=",", na.strings=c("", " ", "  ", "NS"))

points.lookup <- data.frame(achievement_level=c("A", "M", "B", "AB", "U", "B2", "AB2", "F", "PF", "ES", "MS", "WTS"),
										ai_points=c(150, 125, 100, 0, 0, 150, 100, 0, 0, 150, 100, 0)
)

extract.test <- function(r){
	meas <- as.character(r[['measure']])
	first_ <- gregexpr("_", meas)[[1]][1]
	substring(meas, 1, first_-1)
}
extract.subject <- function(r){
	meas <- as.character(r[['measure']])
	first_ <- gregexpr("_", meas)[[1]][1]
	second_ <- gregexpr("_", meas)[[1]][2]
	substring(meas, first_+1, second_-1)
}
extract.type <- function(r){
	meas <- as.character(r[['measure']])
	second_ <- gregexpr("_", meas)[[1]][2]
	substring(meas, second_+1, 100)
}
df.m <- melt(df, id.vars=c("Student.Number"), variable.name="measure", value.name="value", na.rm=T)
df.m$test <- apply(df.m, 1, extract.test)
df.m$subject <- apply(df.m, 1, extract.subject)
df.m$type <- apply(df.m, 1, extract.type)
perc.and.al <- function(d){ 
	nr <- list()

	d.r <- subset(d, type == 'SS')
	if(nrow(d.r) > 0){
    if(d$test[1] == "L13"){
      nr$scaled.score <- as.numeric(d.r[['value']])
      nr$percent <- NA
    }else{
      nr$scaled.score <- NA
      nr$percent <- as.numeric(d.r[['value']])
    }
	}

	d.r <- subset(d, type == 'AL')
	if(nrow(d.r) > 0){
		nr$al <- d.r[['value']]
	}

	return(as.data.frame(nr))
}
df.c <- ddply(df.m, .(Student.Number, test, subject), perc.and.al)
names(df.c) <- c('student_number', "test", "subject", "scaled_score",
                 "percent", "achievement_level"
)
df.c$year <- rep(2014, nrow(df.c))
df.c <- subset(df.c, achievement_level != "0" & !is.na(achievement_level))
df.cp <- merge(df.c, points.lookup)
df.cp$on_level <- apply(df.cp, 1, function(r){
	if(as.numeric(r[['ai_points']]) > 0){
		return(T)
	}else{
		return(F)
	}
})
df.cp$subject <- tolower(df.cp$subject)
df.cp$test <- gsub("M", "MLQ", df.cp$test)
write.csv(df.cp, '../../csvs/scores_import.csv', row.names=F, na="")
