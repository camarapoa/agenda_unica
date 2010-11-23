class Setor < ActiveRecord::Base
  
  belongs_to :setor # Reparticao
  belongs_to :unidade_pai, :class_name => "Setor", :foreign_key => :unidade_pai
  has_many   :lotacoestemporarias
  has_many   :funcionarios, :through => :lotacoestemporarias  
  has_many   :funcionarios, :through => :lotacoes
  has_many   :atribuicoes, :class_name => "Setoratribuicao"
  has_many   :setores_filhos, :class_name => "Setor", :foreign_key => :unidade_pai
    
  default_scope :order => 'nome'
  named_scope   :ativos, :conditions => { :status => 'ativo' }
  
end
