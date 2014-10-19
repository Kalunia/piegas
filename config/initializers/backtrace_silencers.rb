# Be sure to restart your server when you modify this file.

# You can add backtrace silencers for libraries that you're using but don't wish to see in your backtraces.
# Rails.backtrace_cleaner.add_silencer { |line| line =~ /my_noisy_library/ }

# You can also remove all the silencers if you're trying to debug a problem that might stem from framework code.
# Rails.backtrace_cleaner.remove_silencers!

require 'stuff-classifier'

#StuffClassifier::Base.storage = StuffClassifier::InMemoryStorage.new

store = StuffClassifier::FileStorage.new("lib/categories_store.db")
StuffClassifier::Base.storage = store

StuffClassifier::Bayes.open("Positive vs Negative") do |cls|
   	#cls.train_positive()
    #cls.train_negative()
end

StuffClassifier::Base.storage = StuffClassifier::FileStorage.new("lib/categories_store.db")

# StuffClassifier::Bayes.open("Teste") do |cls|
#     cls.train('positivo', "Eu amo programar! Adoro computador!")
#     cls.train('positivo', "Sempre gostei de sorvete e chocolate")
#     cls.train('positivo', "Sou apaixonado por aquela atriz!")
#     cls.train('positivo', "Hoje estou feliz porque ganhei um presente.")
#     cls.train('positivo', "Estou animado para comprar meu celular! Não vejo a hora!")

#     cls.train('negativo', "Odiei aquele restaurante, péssimo serviço")
#     cls.train('negativo', "Rídicula a proposta desse presidente, sempre caluniando")
#     cls.train('negativo', "Muito ruim aquele produto")
#     cls.train('negativo', "Esse celular é muito caro e nem dura nada")
#     cls.train('negativo', "Esse computador é um lixo, sempre com problemas")
    
# end

# @sentClassifier = StuffClassifier::Bayes.open("Teste")
# puts @sentClassifier.classify("Muito lixo esse celular")
# puts @sentClassifier.classify("com problemas, mas adoro assim")
# puts @sentClassifier.classify("O meu pai é adorável e lindo! Adoro ele demais! Feliz dia dos Pais PAI! =D")
# puts @sentClassifier.classify("Odeio Segunda-Feira... Muitos problemas e desanimada =(")

# puts "" 
# puts "Num Pos - "+@sentClassifier.total_word_count_in_cat("positivo").to_s
# puts "Num Neg - "+@sentClassifier.total_word_count_in_cat("negativo").to_s
