function courseGraph(data){
	var w = 1200,
	    h = 300;
			pl = 40,
			pt = 30,
			pb = 110,
			pr = 200,
			rmin = 2,
			rmax = 12;
	
	var yScale = d3.scale.linear()
	    .domain([0, 1])
	    .range([h, 0]);
	
	var dom = [getDate("2013-07-01"), getDate("2014-06-30")]
	var xScale = d3.time.scale()
	    .domain(dom)
	    .range([0, w]);
	
	var rScale = d3.scale.linear()
			.domain([0,data.max_students])
			.range([rmin,rmax])
			
	var shortDateFormat = d3.time.format("%b %e")
	var longDateFormat = d3.time.format("%B %e, %Y")
	var percentFormat = d3.format(".3p");
			
	var assessment_type_names = new Array();
	for (i in data.assessment_types){
		if (assessment_type_names.indexOf(data.assessment_types[i].combined_name) > -1){
		   continue;
		}else{
		   assessment_type_names.push(data.assessment_types[i].combined_name);
		};
	};
	var colorScale = d3.scale.category10()
			.domain(assessment_type_names);
	
	var chart = d3.select("#course_bubble_graph").append("svg")
		.attr("class", "chart")
		.attr("width", w + pl + pr)
		.attr("height", h + pt + pb)
		.append("g")
		.attr("transform", function(d, i) { return "translate(" + pl + "," + pt + ")" })
	;
	
	var yAxisFormat = d3.format(".2p");
	var yAxis = d3.svg.axis()
	                .scale(yScale)
	                .orient("left")
									.ticks(4)
									.tickFormat(yAxisFormat)
	;
	var yAxisArea = chart.append("g")
			 .attr("class", "axis")
			 .attr("transform", "translate(0,0)")
	     .call(yAxis)
	;
	chart.append("g")
			 .attr("class", "rules")
			 .selectAll("line")
	  	 .data(yScale.ticks(4))
			 .enter().append("line")
		   .attr("x1", 0)
		   .attr("x2", w)
		   .attr("y1", yScale)
		   .attr("y2", yScale)
		   .style("stroke", "#ccc")
	;
	
	var tickform = d3.time.format("%b");
	var xAxis = d3.svg.axis()
	                .scale(xScale)
	                .orient("left")
									.ticks(12)
									.tickFormat(tickform)
	;
	var xAxisArea = chart.append("g")
			 .attr("class", "axis")
			 .attr("transform", function(d) { return "rotate (-90) translate(" + -h + ",0)" })
	     // .call(yAxis)
			.call(xAxis)
	;
	var today = new Date();
	chart.append("line")
		   .attr("x1", xScale(getDate(today)))
		   .attr("x2", xScale(getDate(today)))
		   .attr("y1", 0)
		   .attr("y2", h)
		   .style("stroke", "#ccc")
	;
	
	var week_begin = today.setDate(today.getDate()-7);
	chart.append("line")
		   .attr("x1", xScale(getDate(week_begin)))
		   .attr("x2", xScale(getDate(week_begin)))
		   .attr("y1", 0)
		   .attr("y2", h)
		   .style("stroke", "#ccc")
	;
	
	
	var tooltip = d3.select("#course_bubble_graph")
			.append("div")
			.style("position", "absolute")
			.style("z-index", "10")
			.style("visibility", "hidden")
			.text("a simple tooltip")
			.attr("class", "tooltip")
	;
	
	chart.selectAll("circle")
	  .data(data.assessments)
		.enter()
		.append("circle")
	  .attr("cx", function(d) { return xScale(getDate(d.date)); })
	  .attr("cy", function(d) { return yScale(d.average_score); })
		.attr("r", function(d) { return rScale(d.student_count); })
		.attr("fill", function(d) { return colorScale(d.assessment_type_combined_name); } )
		.attr("fill-opacity", 0.75)
		.attr("data-legend",function(d) { return d.assessment_type_combined_name})
		.on("mouseover", function(d, i){return tooltip.style("visibility", "visible").html(
			"<table class=\"graph-hover\">" +
			"<tr><td>Name</td><td> " + d.name + " </td></tr>" +
			"<tr><td>Date</td><td> " + longDateFormat(getDate(d.date)) + " </td></tr>" +
			"<tr><td>Created By</td><td> " + d.staff.last_name + " </td></tr>" +
			"<tr><td>Type</td><td> " + d.assessment_type_combined_name + "</td></tr>" +
			"<tr><td>Average</td><td> " + percentFormat(d.average_score) + "</td></tr>" +
			"<tr><td>Number of Students</td><td> " + d.student_count + " </td></tr></table>"
			);})
		.on("mousemove", function(){return tooltip.style("top", (d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");})
		.on("mouseout", function(){return tooltip.style("visibility", "hidden");}
	);
	
	var line = d3.svg.line()
				.x(function(d) { return xScale(getDate(d.date)); })
				.y(function(d) { return yScale(d.average); })
	
	chart.append("svg:path")
		.attr("d", line(data.class_averages))
		.attr("fill", "none")
		.attr("stroke", "maroon")
	;
	
	legend = chart.append("g")
	  .attr("class","legend")
	  .attr("transform", function(d) { return "translate(" + w + "," + h/2 + ")" })
	  .style("font-size","12px")
	  .call(d3.legend);
	
	// Legend for the size bubbles
	size_legend = chart.append("g")
		.attr("class", "legend")
		.attr("width", 100)
		.attr("height", 100)
		.attr("transform", function(d) { return "translate(" + (w) + "," + ((h/2) - 75) + ")" })
		
	size_legend.append('text')
		.text('0 Students')
		.attr('x', 20);
		
	size_legend.append('circle')
		.attr('r', rmin)
		.attr('cy', -3);
		
	size_legend.append('text')
		.text(function(d){return " " + data.max_students + " students";})
		.attr('y', 30)
		.attr('x', 20);
	
	size_legend.append('circle')
		.attr('r', rmax)
		.attr('cy', 27);
		
	line_legend = chart.append("g")
		.attr("class", "legend")
		.attr("width", 100)
		.attr("height", 100)
		.attr("transform", function(d) { return "translate(" + (w) + "," + ((h/2) - 100) + ")" })
		
	line_legend.append('text')
		.text('Class average')
		.attr('x', 20);
	
	line_legend.append('rect')
		.attr("x", -10)
		.attr("y", -4)
		.attr("width", 18)
		.attr("height", 2)
		.style("stroke", "maroon")
		.style("fill", "maroon")
	;
	
	week_legend = chart.append("g")
		.attr("class", "legend")
		.attr("width", 100)
		.attr("height", 100)
		.attr("transform", function(d) { return "translate(" + (w) + "," + ((h/2) - 125) + ")" })
	;
		
	week_legend.append('text')
		.text('7 Days ending today')
		.attr('x', 20)
	;
	
	week_legend.append('line')
		.attr("x1", 0)
		.attr("y1", -15)
		.attr("x2", 0)
		.attr("y2", 10)
		.style("stroke", "#CCC")
	;
	
	week_legend.append('line')
		.attr("x1", 8)
		.attr("y1", -15)
		.attr("x2", 8)
		.attr("y2", 10)
		.style("stroke", "#CCC")
	;
		
};