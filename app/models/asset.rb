class Asset < ActiveRecord::Base
  
  set_table_name :agenda_eventos_assets
  
  belongs_to :evento
  
  has_attached_file :data,
    :path => "//cmpa-s02/documentos/agenda/:attachment/:id/:basename.:extension",
    :url => "http://200.169.19.94/documentos/agenda/:attachment/:id/:basename.:extension"
	  
	validates_attachment_presence :data, :message => 'deve ser selecionado'                                           
  validate                      :validate_attachment
  
  MAX_FILE_SIZE       = 10.megabytes
  MAX_VIDEO_FILE_SIZE = 20.megabytes
  
  VIDEO_TYPES = %w( video/quicktime )
  
  OTHER_TYPES = %w(
    application/pdf
    application/vnd.ms-excel
    application/msword
    application/rtf
    text/plain
    image/jpeg
    image/png
    image/tiff
    image/gif
    image/bmp
  )
  
  private
  
    def validate_attachment
      errors.add_to_base('Formato de arquivo não suportado') unless (VIDEO_TYPES + OTHER_TYPES).include?(data_content_type)
      
      if VIDEO_TYPES.include?(data_content_type) && data_file_size > MAX_VIDEO_FILE_SIZE
        errors.add_to_base "Vídeo selecionado é maior que o tamanho máximo permitido (#{ helpers.number_to_human_size MAX_VIDEO_FILE_SIZE })"
      elsif OTHER_TYPES.include?(data_content_type) && data_file_size > MAX_FILE_SIZE
        errors.add_to_base "O arquivo selecionado é maior que o tamanho máximo permitido (#{ helpers.number_to_human_size MAX_FILE_SIZE })"
      end
    end
    
    def helpers
      ActionController::Base.helpers
    end
end