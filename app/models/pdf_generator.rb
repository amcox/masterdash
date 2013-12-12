class PdfGenerator
  require 'pdfkit'
  
  def initialize(html)
    @kit = PDFKit.new(html)
    @kit.stylesheets << "#{Rails.root}/public/assets/application.css"
  end
  
  def export_file(save_path)
    @kit.to_file(save_path)
  end
  
end