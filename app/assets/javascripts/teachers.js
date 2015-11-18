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