#require 'chronic'

class UtilDate
  
  def self.to_date(data, format = '%d/%m/%Y')       
    Date.strptime(data, format)    
    return Date.strptime(data, format)
  rescue Exception => e    
    return nil
  end
  
  # Retorna um datetime fazendo a união de <date> e <time> e convertendo
  # no formato especificado por <format>
  def self.to_datetime(date, time, format = '%Y-%m-%d %H:%M:%S')    
    return DateTime.strptime(date.to_date.to_s + ' ' + time.to_s, format)
  rescue Exception => e    
    return nil
  end  
  
  def self.periodo_valido?(data_inicio, horario_inicio, data_termino, horario_termino)          
      return false if !data_inicio.present? || !data_termino.present?    
      inicio  = self.to_datetime(data_inicio, horario_inicio + ':00')      
      termino = self.to_datetime(data_termino, horario_termino + ':00')            
      return inicio < termino       
  end
  
  def self.month_to_s(month_int)
    month_names =  [nil] + %w(Janeiro Fevereiro Março Abril Maio Junho Julho Agosto Setembro Outubro Novembro Dezembro)    
    return month_names[month_int]
  end
  
  def self.day_to_s(day_int)
    day_names = %w(Domingo Segunda Terça Quarta Quinta Sexta Sábado)
    return day_names[day_int]
  end
  
  def self.date_time_intervals(begin_time, end_time, min_interval = 30)
		curr_time = DateTime.parse(begin_time)
		finish_time  = DateTime.parse(end_time)
		
		intervals = []
		while curr_time <= finish_time
		  intervals << curr_time.strftime('%Y%m%d %H:%M')
		  curr_time += min_interval.minutes
		end
		intervals
	end
  
end