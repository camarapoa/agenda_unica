class LogEvento < ActiveRecord::Base  

  belongs_to :evento
  
  serialize :history
  
  set_table_name :agenda_logs_eventos

  named_scope :recentes, lambda { { :conditions => ['updated_at > ?', 1.week.ago], :order => 'evento_id, updated_at DESC' } }
  
end