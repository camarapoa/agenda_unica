class Evento < ActiveRecord::Base

  formatted_date :data_inicio, :data_termino
  #acts_as_paranoid  

  after_update :save_changes_to_log
  after_create :save_create_to_log

  belongs_to :local
  belongs_to :projeto, :class_name => 'Projeto', :foreign_key => :processo_id
  belongs_to :tipo_evento
  has_many   :assets, :dependent => :destroy
  has_many   :eventos_servicos
  has_many   :servicos, :through => :eventos_servicos
  has_many   :recursos_alocados, :dependent => :destroy
  has_many   :recursos_eventos, :through => :recursos_alocados
  has_many   :locais, :through => :locais_eventos
  has_many   :logs, :class_name => 'LogEvento'  
  belongs_to :setor_solicitante, :class_name => 'Setor', :foreign_key => 'setor_solicitante_id'	
  has_one		 :emprestimo
  
  set_table_name :agenda_eventos
    
  accepts_nested_attributes_for :assets, :reject_if => lambda { |attributes| attributes.all? { |k, v| v.blank? } }
  
  validates_presence_of     :contato, :titulo, :tipo_evento_id, :horario_inicio, :horario_termino, :proponente, :categoria
  validates_presence_of     :data_inicio, :data_termino
  validates_numericality_of :processo_id, :allow_nil => true

  named_scope :periodicos, :conditions => ['data_inicio <> data_termino']
  named_scope :nao_periodicos, :conditions => ['data_inicio = data_termino']
  named_scope :reservados, :conditions => { :status => :reservado }, :order => 'data_inicio, horario_inicio'
  named_scope :confirmados, :conditions => { :status => :confirmado }, :order => 'data_inicio, horario_inicio'
  named_scope :cancelados, :conditions => { :status => :cancelado }, :order => 'data_inicio, horario_inicio'  
  named_scope	:atualizados_recentemente, :include => :logs, :conditions => ["#{LogEvento.table_name}.updated_at > ?", 1.week.ago], :order => :data_inicio  
  named_scope :ativos, :conditions => ["status <> 'cancelado' and  convert(datetime, data_termino + horario_termino) >= getdate()"], :order => 'data_inicio, horario_inicio'    
  #named_scope	:do_dia, lambda { |date| { :include => :tipo_evento, :conditions => ["? between data_inicio and  data_termino " , date] } }
  named_scope	:do_dia, lambda { |date| { :conditions => ["? between data_inicio and  data_termino " , date] } }
  named_scope :do_mes, lambda { |mes, ano| { :conditions => ['(datepart(month,data_inicio) = ? or datepart(month,data_termino) = ?) AND (datepart(year,data_inicio) = ? or datepart(year, data_termino) = ?)', mes, mes, ano, ano] }}
  named_scope :por_categoria, :group_by => "#{TipoEvento.table_name}.categoria"
  named_scope :status_equals, lambda { |status| { :conditions => { :status => status } } }
  named_scope :tipo_evento_id_equals, lambda { |tipo_evento_id| { :conditions => { :tipo_evento_id => tipo_evento_id } } }
  named_scope :data_inicio_equals, lambda { |date| { :conditions => { :data_inicio => date } } }
  named_scope :data_termino_equals, lambda { |date| { :conditions => { :data_termino => date } } }
  named_scope :periodo_between, lambda { |inicio, termino| { :conditions => ['data_inicio >= ? AND data_termino <= ?', inicio.beginning_of_day, termino.end_of_day] } }
  # owner é o setor gerente
  named_scope :por_owner,  lambda { |owner| { :conditions => { :setor_gerente_id => owner } } }

  STATUS = %w( cancelado confirmado reservado )
  CATEGORIAS = [['Aberto ao Público', 'aberto_ao_publico'], ['Interno','interno']]

  def cancelado?;  status == 'cancelado'  end
  def confirmado?; status == 'confirmado' end
  def reservado?;  status == 'reservado'  end

  def cancelar!
    #update_attribute :status, 'cancelado'
    self.status = 'cancelado'
    self.save(false)
  end

  def confirmar!
    #update_attribute :status, 'confirmado'
    self.status = 'confirmado'
    self.save(false)
  end

  def processo_existente?
    Projeto.exists? [ "numero = ? AND ano = ?", @processo.strip.split('/')[0], @processo.strip.split('/')[1] ]
  end

  def processo_valido?
    s = @processo.strip.split('/')
    !(s.size != 2 || s[0].size != 5 || s[1].size != 4)
  end

  def processo
    projeto ? "#{projeto.numero.strip}/#{projeto.ano}" : @processo
  end

  def processo=(value)
    @processo = value
  end

  def created_by?(user)
    created_by == user.id
  end

  def past?
    data_termino < Time.now.to_date
  end

  def self.search(evento)
    scope = scoped    
    scope = scope.status_equals(evento.status) if evento.status.present?
    scope = scope.do_dia(evento.data_inicio) if evento.data_inicio.present? && evento.data_termino.blank?
    #scope = scope.data_termino_equals(evento.data_termino) if evento.data_inicio.present? && evento.data_termino.present?
    scope = scope.periodo_between(evento.data_inicio, evento.data_termino) if evento.data_inicio.present? && evento.data_termino.present?
    scope = scope.tipo_evento_id_equals(evento.tipo_evento_id) if evento.tipo_evento_id.present?
    scope
  end

  def periodo_valido?
    if (!self.data_inicio || !self.data_termino) || ((data_inicio && data_termino) && (data_inicio > data_termino))
      errors.add_to_base('Período inválido')
      return false
    else
      return true
    end
  end

  protected

    def validate
      if processo.present?
        errors.add(:processo, 'deve estar no formato numero/ano (ano com 4 dígitos)') unless processo_valido?
        errors.add(:processo, 'não encontrado no Sisprot') unless processo_existente?        
      end
      inicio, fim = FormattedDate::Conversion.to_datetime("#{data_inicio_before_type_cast} #{horario_inicio}", "#{data_termino_before_type_cast} #{horario_termino}", :format => '%d/%m/%Y %H:%M')
      errors.add_to_base('Período do evento inválido') if !inicio || !fim || inicio >= fim
      errors.add_to_base("Local ou Outro Local devem ser informados") if !self.local_id.present? && !self.outro_local.present?
      #verificação de pré-agendamento de espaço      
      errors.add_to_base('Local já reservado para outro evento no período') if data_inicio && data_termino && !Local.espaco_disponivel?(self, nil, self.local, "#{self.data_inicio.strftime('%Y%m%d')} #{self.horario_inicio}"  ,  "#{self.data_termino.strftime('%Y%m%d')} #{self.horario_termino}")      
      errors.add_to_base('Às terças-feiras, das 8h30min às 19h, as salas de comissões e plenarinho podem ser agendados somente para reuniões de comissões e por funcionários vinculados a elas (Setor e Seção de Comissões e comissões permanentes)')  if Local.restricoes_comissoes?(self)
      errors.add_to_base('A Comissão deve ser informada em caso do Tipo de Evento ser Reunião de COmissão') if self.tipo_evento_id == 8 && !self.comissao_id.present?
    end

    def before_create
      self.status = 'reservado'            
    end

    def before_save
      if @processo.present? && processo_valido? && processo_existente?
        @processo.split('/')[1]
        self.processo_id = Projeto.find_by_numero_and_ano(@processo.split('/')[0], @processo.split('/')[1]).id
      end
    end

    def save_changes_to_log    	
    	begin
	      return if changes.empty?      
	      _changes = changes.clone
	      _changes.delete('deleted_at')
	      LogEvento.create :history => _changes, :evento_id => id, :updated_by => Pessoa.find(updated_by).nome
	    rescue Exception => e	    	
				email = EventoMailer.create_envia_notificacao_erro_historico(self, _changes, Pessoa.find(updated_by), e)
      	email.set_content_type 'text/html'      		
	    end  
    end
    
    def save_create_to_log
    	begin	      
	       LogEvento.create(:history =>  {'new_evento' => 'new_evento'} , :evento_id => self.id, :updated_by => Pessoa.find(self.created_by).nome)
	    rescue Exception => e	    	
				email = EventoMailer.create_envia_notificacao_erro_historico(self, 'novo evento', Pessoa.find(updated_by), e)
      	email.set_content_type 'text/html'      		
	    end  
    end    
    
end