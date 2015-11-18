function createTeacherAIGraphPlotly(data){
console.log("TeacherAIGraphPlotly test")
var trace1 = {
  x: data.teacher_x, 
  y: data.teacher_y, 
  name: 'Teacher', 
  type: 'bar',
  marker: {color: 'rgb(55, 83, 109)'}
};

var trace2 = {
  x: data.network_x, 
  y: data.network_y, 
  name: 'ReNEW', 
  type: 'bar'
};

var data = [trace1, trace2];

console.log(data)

var layout = {barmode: 'group',
   title: '2015-16 Network Assessments AI'};

Plotly.newPlot('teacher_ai_graph', data, layout);

};