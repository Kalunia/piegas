# a Gem 'Classifier' foi conhecida e utilizada de acordo com o fórum
# https://www.igvita.com/2007/05/23/bayes-classification-in-ruby/
# ao qual foi adaptado (a seguir) por Pedro Grandin e utilizado para controle de spams

class ClassifierClass

require 'rubygems'

	def self.initialize_classifier (spam, not_spam)
		@classifier = Classifier::Bayes.new('Not Spam', 'Spam')

		not_spam.each { |good| @classifier.train_not_spam good }
		spam.each { |spam| @classifier.train_spam spam }
	end


	def self.classify_tweet (text)
	  	@classifier.classify text
	end

end