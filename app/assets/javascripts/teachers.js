function createTeacherAIGraph() {
	var json_path = $("div#teacher_ai_graph").attr("data-json_path");
	d3.json(json_path, function(error, returned_json) {
	  if (error) return console.warn(error);
	  console.log("In teacher AI graph")
	  createTeacherAIGraphPlotly(returned_json);
	});
};

$(document).ready(function() {
	if ($("div#teacher_ai_graph").length > 0) {
		createTeacherAIGraph();
	};
});


function createTeacherBulletGraph() {
	var json_path = $("div#teacher_bullet_graph").attr("data-json_path");
	d3.json(json_path, function(error, returned_json) {
	  if (error) return console.warn(error);
	  console.log("In teacher bullet graph")
	  });

	var margin = {top: 5, right: 40, bottom: 20, left: 120},
    width = 960 - margin.left - margin.right,
    height = 50 - margin.top - margin.bottom;

	var chart = d3.bullet()
    .width(width)
    .height(height);
	  
    var svg = d3.select("body").selectAll("svg")
      .data(data)
    .enter().append("svg")
      .attr("class", "bullet")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
      .call(chart);

  var title = svg.append("g")
      .style("text-anchor", "end")
      .attr("transform", "translate(-6," + height / 2 + ")");

  title.append("text")
      .attr("class", "title")
      .text(function(d) { return d.title; });

  title.append("text")
      .attr("class", "subtitle")
      .attr("dy", "1em")
      .text(function(d) { return d.subtitle; });

	  NewTeacherBulletGraph(returned_json);
};

$(document).ready(function() {
	if ($("div#teacher_bullet_graph").length > 0) {
		createTeacherBulletGraph();
	};
});

