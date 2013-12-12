class TemplateInterpreter
  require 'haml'
  
  attr_accessor :local_names
  
  def initialize(haml_file)
      @he = Haml::Engine.new(File.read(haml_file))
      @local_names = []
      build_render_proc
  end
  
  def build_render_proc
    if local_names.empty?
      @render_proc = @he.render_proc(Object.new)
    else
      @render_proc = @he.render_proc(Object.new, *local_names)
    end
  end
  
  def render(local_values)
    @render_proc.call(local_values)
  end

end