class StudentDataTracker
  attr_accessor :save_root
  
  def initialize
    @template = TemplateInterpreter.new("#{Rails.root}/app/views/students/student_data_tracker.html.haml")
    @template.local_names = [:student_name, :student_grade, :student_subject,
      :leap_scaled_score, :leap_al, :mlqs, :benchmarks
    ]
    @template.build_render_proc
    @save_root = "#{Rails.root}/output/trackers"
  end
  
  def make_pdf(html, file_path)
    PdfGenerator.new(html).export_file(file_path)
  end
    
  def build_for_student_subject(student, subject, save_path)
    student_values = {student_name: student.name,
      student_grade: student.grade_in_words, student_subject: Formatter.subject_long(subject),
      leap_scaled_score: nil, leap_al: nil, benchmarks: {}, mlqs: {}
    }
    mlqs = {}
    benchmarks = {}
    student.scores.where(subject: subject).includes(:test).each do |s|
      case
      when s.test.name == "L13"
        student_values[:leap_scaled_score] = s.scaled_score
        student_values[:leap_al] = Formatter.achievement_level_long(s.achievement_level)
      when s.test.name =~ /MLQ/
        mlq_num = s.test.name.match(/\d/).to_s.to_i
        mlqs[mlq_num] = {score: Formatter.percent_format(s.percent), 
          al: Formatter.achievement_level_long(s.achievement_level)}
      when s.test.name =~ /B/
        benchmarks[s.test.name.to_sym] = {score: Formatter.percent_format(s.percent),
          al: Formatter.achievement_level_long(s.achievement_level)}
      end
    end
    student_values[:mlqs] = mlqs
    student_values[:benchmarks] = benchmarks
    
    html = @template.render(student_values)
    make_pdf(html, "#{save_path}/#{student.name} ELA Data Tracker.pdf")
  end
  
  def build_set
    sections = Enrollment.unique_sections
    sections.each do |sec|
      desired_dir = "#{@save_root}/#{sec.school}/#{sec.subject}/#{sec.teacher.name}/#{sec.section}"
      FileUtils.mkdir_p(desired_dir) unless Dir.exists?(desired_dir)
      students = Student.find(Enrollment.where{(school == sec.school) & (teacher_id == sec.teacher_id) & (subject == sec.subject) & (section == sec.section)}.pluck(:student_id))
      students.each do |student|
        build_for_student_subject(student, sec.subject, desired_dir)
      end
    end
  end
  
end