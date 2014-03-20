b_and_above <- function(df){
		a_r <- subset(df, level == "adv", na.rm=TRUE)
		m_r <- subset(df, level == "mast", na.rm=TRUE)
		b_r <- subset(df, level == "basic", na.rm=TRUE)
		all <- c(as.numeric(b_r$perc), as.numeric(m_r$perc), as.numeric(a_r$perc))
    return(sum(all))
}