movement_counts <- function(first.als, second.als){
  # Takes in two vectors of ALs, the first and second scores,
  # returns a data frame of the counts and percents of movement.
  
  counts <- table(first.als, second.als)
	percs <- prop.table(counts, 1)
	df.counts <- melt(counts, varnames=c("first", "second"), value.name="count")
	df.percents <- melt(percs, varnames=c("first", "second"), value.name="perc")
	df.out <- merge(df.counts, df.percents)
	df.out$first <- reorder(df.out$first, new.order=al.order)
	df.out$second <- reorder(df.out$second, new.order=al.order)
  df.out$movement.category <- apply(df.out, 1, function(r){
    if(al.nums[[r['first']]] > al.nums[[r['second']]]){
      return('down')
    } else{
      if(al.nums[[r['first']]] < al.nums[[r['second']]]){
        return('up')
      } else{
        return('a-same')
      }
    }
  })
	return(df.out)
}

movement_plot <- function(df, title, first.lab, second.lab, text.size=6){
  # Takes in a data frame with the counts and percents of movement, as created
  # by movement_counts. Returns the movement grid plot.
  
	p <- ggplot(df[order(df$movement.category), ], aes(x=second, y=first))+
  	geom_tile(aes(fill=perc, color=movement.category), size=.25)+
  	geom_text(aes(label=paste0(round(perc*100,0),"%\n(",count,")")), size=text.size)+
  	scale_fill_continuous(low = "white", high = "#96AFFF", na.value="white",
  		name="Number of Scores"
    )+
    scale_color_manual(values=c("up"="#6CCC77", "down"="#CC6C6C", "a-same"="white"))+
  	coord_fixed()+
  	theme_bw()+
  	labs(title=title,
      x=second.lab,
      y=first.lab
    )+
  	theme(legend.position="none"
    )
	return(p)
}

make_movement_plot_with_n <- function(first.als, second.als, title.string, first.lab, second.lab) {
	d <- movement_counts(first.als, second.als)
  print(d)
	total <- sum(d$count)
	title <- paste0(title.string, " (n=", total, ")")
	p <- movement_plot(d, title=title, first.lab, second.lab)
  return(p)
}