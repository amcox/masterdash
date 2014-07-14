b_and_above <- function(df){
		a_r <- subset(df, achievement.level == "A", na.rm=TRUE)
		m_r <- subset(df, achievement.level == "M", na.rm=TRUE)
		b_r <- subset(df, achievement.level == "B", na.rm=TRUE)
		all <- c(as.numeric(b_r$perc), as.numeric(m_r$perc), as.numeric(a_r$perc))
    data.frame(perc.cr=sum(all))
}