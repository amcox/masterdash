library(stringr)
library(dplyr)
library(tidyr)

read_and_add_name <- function(filename) {
  d <- read.csv(filename, head=TRUE, na.string=c('', ' '), stringsAsFactors=F)
  d$test <- rep(str_extract(basename(filename), '\\w*'), nrow(d))
  return(d)
}

load_all_from_raw <- function(dir=NULL) {
  filenames <- list.files(paste0("./raw", dir), pattern=".csv", full.names=TRUE)
  ldf <- lapply(filenames, read_and_add_name)
  d <- rbind_all(ldf)
  return(d)
}

cut_al <- function(vec) {
  cut(vec, breaks=c(-999, 0.45, 0.5, 0.75, 0.9, 9999),
    labels=c('U', 'AB', 'B', 'M', 'A'), right=F
  )
}

cut_by_grade <- function(d) {
    d$achievement_level <- cut_al(d$percent)
  return(d)
}

ai.points <- data.frame(
  achievement_level=c('A', 'M', 'B', 'AB', 'U', 'WTS', 'MS', 'ES', 'PF', 'F', 'AB2', 'B2'),
  ai_points=c(150, 125, 100, 0, 0, 0, 100, 150, 0, 0, 100, 150)
)

# Load and process data from DCI tests
df <- load_all_from_raw()
d <- df %>% gather(subject, percent, ela:soc, na.rm=T)
d <- d %>% group_by(grade) %>% mutate(achievement_level=cut_al(percent))
d <- data.frame(d)
# d <- select(d, -grade)
d$scaled_score <- rep(NA, nrow(d))

# Load and process data from LEAP tests
dl <- read.csv('leap.csv', head=TRUE, na.string=c('', ' '), stringsAsFactors=F)
dl <- dl %>% gather(var, value, -student_number, na.rm=T)
dl <- dl %>% separate(var, c('subject', 'measure'), '\\.')
dl <- dl %>% spread(measure, value)
dl$test <- rep('L14', nrow(dl))
dl$percent <- rep(NA, nrow(dl))

# Put together and add columns
db <- rbind(d, dl)
db$year <- rep('2016', nrow(db))
db <- merge(db, ai.points)
db <- db %>% mutate(on_level = ai_points > 0)

# Save to a scores import file
write.csv(db, './../scores_import.csv', row.names=F, na='')