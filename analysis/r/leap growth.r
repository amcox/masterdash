library(plyr)
library(dplyr)
library(gdata)
library(reshape2)
library(ggplot2)
library(scales)
library(gridExtra)
library(stringr)

update_functions <- function() {
	old.wd <- getwd()
	setwd("functions")
	sapply(list.files(), source)
	setwd(old.wd)
}
update_functions()

con <- prepare_connection()
df <- create_student_school_scores_roll_up(con)

pp <- ddply(df, .(school, grade, subject, test_name), b_and_above)
names(pp)[names(pp)=="V1"] <- "perc.cr"

cr.growth <- ddply(pp, .(school, grade, subject), function(d){
  l13 <- subset(d, test_name == 'L13')
  l14 <- subset(d, test_name == 'L14')
  return(as.numeric(l14['perc.cr'])- as.numeric(l13['perc.cr']))
})
names(cr.growth)[names(cr.growth)=="V1"] <- "perc.prof.growth"

cr.growth <- subset(cr.growth, !is.na(perc.prof.growth) & grade != 3 & grade != '0_8')

cr.growth$grade <- str_replace_all(cr.growth$grade, "-", "_")
save_df_as_csv(cr.growth, "cr growth from 2013 to 2014")

cr.growth$grade <- factor(cr.growth$grade)
cr.growth$grade <- reorder(cr.growth$grade, new.order=cr.growth.grades)
cr.growth$school <- factor(cr.growth$school)
cr.growth$school <- reorder(cr.growth$school, new.order=schools)

p <- ggplot(cr.growth, aes(x=school, y=perc.prof.growth))+
  geom_bar(stat="identity")+
  scale_y_continuous(labels=percent, breaks=seq(-1, 1, .1))+
  labs(title="Growth in Percent Basic and Above from 2013 to 2014",
    x="School",
    y="Percentage Point Change in Percent Basic and Above from 2013 to 2014"
  )+
  theme_bw()+
  theme(axis.text.x=element_text(angle=90, vjust=0.5),
    axis.text.y=element_text(size=7)
  )+
  facet_grid(subject~grade)
save_plot_as_pdf(p, "Growth in Percent Basic and Above from 2013 to 2014")