# library(plyr)
# library(dplyr)
library(gdata)
library(reshape2)
library(ggplot2)
library(scales)
library(gridExtra)

update_functions <- function() {
	old.wd <- getwd()
	setwd("functions")
	sapply(list.files(), source)
	setwd(old.wd)
}
update_functions()

con <- prepare_connection()

df.bench <- get_single_score_per_student_with_student_data(con)
df.bench <- subset(df.bench, test_name == 'B3' & grade < 3 & subject %in% c("ela", "math"))
df.bench$subject <- gsub("ela", "reading", df.bench$subject)
df.bench <- df.bench[, !names(df.bench) %in% c("id")]

df.map <- read.csv('./../Data/map data all.csv', na.string=c("", " ", "  "))
df.map <- df.map[, !names(df.map) %in% c("last.name", "first.name", "grade", "school")]

df <- merge(df.bench, df.map, by.x=c("student_number", "subject"), by.y=c("id", "subject"))

# Scatterplot of bench and MAP
p <- ggplot(df, aes(x=percent, y=winter.percentile))+
  geom_point()+
  geom_smooth()+
  scale_y_continuous(limits=c(0,100))+
  scale_x_continuous(labels=percent)+
  labs(title="Winter MAP and Benchmark 3 Comparison, By Grade and Subject",
    x="Percent Correct on Benchmark 3",
    y="National Percentile Rank on Winter MAP"
  )+
  theme_bw()+
  facet_grid(subject ~ grade)

save_plot_as_pdf(p, "Winter MAP and Benchmark 3 Comparison")

# Boxplot of students scoring above 80% on 
df$above80 <- cut(df$percent, c(-1, .799, 1.1),
  labels=c("below 80", "80 or above"), right=FALSE
)
p <- ggplot(df, aes(x=above80, y=winter.percentile))+
  geom_boxplot(outlier.size=0, notch=T)+
  geom_jitter(position=position_jitter(width=.4, height=0), alpha=0.25)+
  scale_y_continuous(limits=c(0,100))+
  labs(title=paste0("Winter MAP and Benchmark 3 Comparison, By Grade and Subject\n",
      "Grouped by Students Scoring ≥ 80% on the Benchmark"
    ),
    x="Percent Correct on Benchmark 3",
    y="National Percentile Rank on Winter MAP"
  )+
  theme_bw()+
  facet_grid(subject ~ grade)
save_plot_as_pdf(p, "Winter MAP and Benchmark 3 Comparison, by 80 Percent")

# Save the data frame as a csv
save_df_as_csv(df, "Benchmark 3 and MAP Scores")