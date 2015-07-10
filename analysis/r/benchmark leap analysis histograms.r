library(dplyr)
library(dplyr)
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

df <- get_single_score_per_student_with_student_data(con)

get_matched_bench_leap_scores <- function(d, bench.name) {
  d.b <- subset(df, test_name == bench.name)
  d.l14 <- subset(df, test_name == 'L14' & achievement_level %in% leap.als)

  d.bs <- d.b[, c("student_id", "subject", "achievement_level", "percent", "grade", "school")]
  names(d.bs)[names(d.bs) == 'achievement_level'] <- 'b.al'
  names(d.bs)[names(d.bs) == 'percent'] <- 'b.percent'
  d.l14s <- d.l14[, c("student_id", "subject", "achievement_level", "scaled_score", "grade", "school")]
  names(d.l14s)[names(d.l14s) == 'achievement_level'] <- 'l14.al'
  names(d.l14s)[names(d.l14s) == 'scaled_score'] <- 'l14.scaled_score'

  dm <- merge(d.bs, d.l14s)
}

make_al_dist_plot <- function(d, test.name, more.title=NULL) {
  ggplot(d, aes(x=h.mids, y=h.counts, color=l14.al))+
    geom_line()+
    scale_x_continuous(labels=percent, breaks=seq(0, 1, .1))+
    scale_color_discrete(name="L14 AL")+
    labs(x=paste0('Percent Correct on ', test.name),
      y='Number of Students',
      title=paste0("Achievement Levels of Students According to ", test.name, " Scores", more.title)
    )+
    theme_bw()
}

# Run graphs for just Benchmark 3
dm <- get_matched_bench_leap_scores(df, "B3")

dc <- dm %>% group_by(l14.al, subject) %>% do(get_counts(., 'b.percent', seq(0,1,.05)))
dc$l14.al <- reorder.factor(dc$l14.al, new.order=leap.als)
p <- make_al_dist_plot(dc, "Benchmark 3") + facet_wrap(~subject) + theme(axis.text.x=element_text(size=6))
save_plot_as_pdf(p, 'LEAP and Benchmark 3 AL Comparison, by Subject')

dc <- dm %>% group_by(l14.al) %>% do(get_counts(., 'b.percent', seq(0,1,.05)))
dc$l14.al <- reorder.factor(dc$l14.al, new.order=leap.als)
p <- make_al_dist_plot(dc, "Benchmark 3", ", All Subjects")
save_plot_as_pdf(p, 'LEAP and Benchmark 3 AL Comparison, All Subjects')

dc <- dm %>% group_by(l14.al, subject, grade) %>% do(get_counts(., 'b.percent', seq(0,1,.05)))
dc$l14.al <- reorder.factor(dc$l14.al, new.order=leap.als)
p <- make_al_dist_plot(dc, "Benchmark 3", ", By Grade and Subject") + facet_grid(subject ~ grade) + theme(axis.text.x=element_text(size=4))
save_plot_as_pdf(p, 'LEAP and Benchmark 3 AL Comparison, by Subject and Grade')


# Run graphs for just Benchmark 2
dm <- get_matched_bench_leap_scores(df, "B2")

dc <- dm %>% group_by(l14.al, subject) %>% do(get_counts(., 'b.percent', seq(0,1,.05)))
dc$l14.al <- reorder.factor(dc$l14.al, new.order=leap.als)
p <- make_al_dist_plot(dc, "Benchmark 2") + facet_wrap(~subject) + theme(axis.text.x=element_text(size=6))
save_plot_as_pdf(p, 'LEAP and Benchmark 2 AL Comparison, by Subject')

dc <- dm %>% group_by(l14.al) %>% do(get_counts(., 'b.percent', seq(0,1,.05)))
dc$l14.al <- reorder.factor(dc$l14.al, new.order=leap.als)
p <- make_al_dist_plot(dc, "Benchmark 2", ", All Subjects")
save_plot_as_pdf(p, 'LEAP and Benchmark 2 AL Comparison, All Subjects')

dc <- dm %>% group_by(l14.al, subject, grade) %>% do(get_counts(., 'b.percent', seq(0,1,.05)))
dc$l14.al <- reorder.factor(dc$l14.al, new.order=leap.als)
p <- make_al_dist_plot(dc, "Benchmark 2", ", By Grade and Subject") + facet_grid(subject ~ grade) + theme(axis.text.x=element_text(size=4))
save_plot_as_pdf(p, 'LEAP and Benchmark 2 AL Comparison, by Subject and Grade')


# Run graphs for just Benchmark 1
dm <- get_matched_bench_leap_scores(df, "B1")

dc <- dm %>% group_by(l14.al, subject) %>% do(get_counts(., 'b.percent', seq(0,1,.05)))
dc$l14.al <- reorder.factor(dc$l14.al, new.order=leap.als)
p <- make_al_dist_plot(dc, "Benchmark 1") + facet_wrap(~subject) + theme(axis.text.x=element_text(size=6))
save_plot_as_pdf(p, 'LEAP and Benchmark 1 AL Comparison, by Subject')

dc <- dm %>% group_by(l14.al) %>% do(get_counts(., 'b.percent', seq(0,1,.05)))
dc$l14.al <- reorder.factor(dc$l14.al, new.order=leap.als)
p <- make_al_dist_plot(dc, "Benchmark 1", ", All Subjects")
save_plot_as_pdf(p, 'LEAP and Benchmark 1 AL Comparison, All Subjects')

dc <- dm %>% group_by(l14.al, subject, grade) %>% do(get_counts(., 'b.percent', seq(0,1,.05)))
dc$l14.al <- reorder.factor(dc$l14.al, new.order=leap.als)
p <- make_al_dist_plot(dc, "Benchmark 1", ", By Grade and Subject") + facet_grid(subject ~ grade) + theme(axis.text.x=element_text(size=4))
save_plot_as_pdf(p, 'LEAP and Benchmark 1 AL Comparison, by Subject and Grade')

# Run graphs for all Benchmarks, faceted
dm1 <- get_matched_bench_leap_scores(df, "B1")
dm1$bench <- rep(1, nrow(dm1))
dm2 <- get_matched_bench_leap_scores(df, "B2")
dm2$bench <- rep(2, nrow(dm2))
dm3 <- get_matched_bench_leap_scores(df, "B3")
dm3$bench <- rep(3, nrow(dm3))

dma <- rbind(dm1, dm2, dm3)

dc <- dma %>% group_by(l14.al, subject, bench) %>% do(get_counts(., 'b.percent', seq(0,1,.05)))
dc$l14.al <- reorder.factor(dc$l14.al, new.order=leap.als)
p <- make_al_dist_plot(dc, "All Benchmarks") + facet_grid(bench~subject) + theme(axis.text.x=element_text(size=5))
save_plot_as_pdf(p, 'LEAP and All Benchmark AL Comparison, by Subject')

dc <- dma %>% group_by(l14.al, bench) %>% do(get_counts(., 'b.percent', seq(0,1,.05)))
dc$l14.al <- reorder.factor(dc$l14.al, new.order=leap.als)
p <- make_al_dist_plot(dc, "All Benchmarks", ", All Subjects") + facet_wrap(~ bench, nrow=3) + theme(axis.text.x=element_text(size=5))
save_plot_as_pdf(p, 'LEAP and All Benchmarks AL Comparison, All Subjects', wide=F)
