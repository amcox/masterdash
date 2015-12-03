function createTeacherAIGraphPlotly(data){
console.log("TeacherAIGraphPlotly test")
var teacher = {
  x: data.teacher_x, 
  y: data.teacher_y, 
  name: 'Teacher', 
  type: 'bar',
  marker: {color: 'rgb(55, 83, 109)'}
};

var network = {
  x: data.network_x, 
  y: data.network_y, 
  name: 'ReNEW', 
  type: 'bar'
};

var data = [teacher, network];

console.log(data)

var layout = {barmode: 'group',
   title: '2015-16 Network Assessments AI', 
   titlefont: {size: 24}, 
   yaxis: {range: [0, 150]}
 };

Plotly.newPlot('teacher_ai_graph', data, layout);

};