# Sobre escrita do método titleize
# => stopwords são ignoradas
# => siglas são transformadas em maiúsculas
# Observação: a primeria palavra da string será transformada com capitalize
# => Exemplo: 'a branca de neve e os 7 anões do pt'.titleize retorna
#             'A Branca de Neve e os 7 Anões do PT'
class String
  STOPWORDS = %w(a e o as os da de do das dos em um uma uns umas que para com por não no na nos nas
              se mais como mas ao aos ou eu ele ela eles elas seu sua seus suas quando muito
              já também só pelo pela até isso entre depois sem mesmo quem me esse)
              
  SIGLAS = %w(pdt dem pmdb pp pc b psdb pr pt ptb pps psl psb pfl phs ascam ccj cece ctg
              cuthab abecapa abrascam lti cefor cedecondh cosmam cipa demhab gt)
  
  def titleize
    s = []
    self.humanize.underscore.split.each_with_index do |word, i|
      if !(STOPWORDS.include?(word) || SIGLAS.include?(word))
        s << word.gsub(/\b('?[a-z])/) { $1.capitalize }
      elsif SIGLAS.include?(word)
        s << word.upcase
      elsif i == 0
        s << word.capitalize
      else
        s << word
      end
    end
    s.join(" ").strip
  end
end