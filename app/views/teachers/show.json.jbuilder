x_values_t = []
y_values_t = []

@teacher.ai_by_test.each do |k, v|
	x_values_t.push k
	y_values_t.push v
end

x_values_n = []
y_values_n = []

@teacher.network_comparison_ai_by_test.each do |k, v|
	x_values_n.push k
	y_values_n.push v
end


json.teacher_x x_values_t
json.teacher_y y_values_t
json.network_x x_values_n
json.network_y y_values_n

title= "Observations"
subtitle = "Average Rating"
ranges = [1.5,2.5,3.5,4]
measures = [2.2]
markers = [2.2]

json.title title
json.subtitle subtitle
json.ranges ranges
json.measures measures
json.markers markers