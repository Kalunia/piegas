class ClassifierClass

require 'rubygems'
require 'yaml'
require 'stemmer'	

	def self.initialize_classifier
		@classifier = Classifier::Bayes.new('Spam', 'Not Spam')

		spam = YAML::load_file(File.join('public/yaml/', 'spam.yml'))
		not_spam = YAML::load_file(File.join('public/yaml/', 'not_spam.yml'))

		spam.each { |spam| @classifier.train_spam spam }
		not_spam.each { |good| @classifier.train_not_spam good }
	end


	def self.classify_tweet (text)

	  	@classifier.classify text
	end

	def self.add_spam (post)

		open('public/yaml/spam.yml', 'a') { |f|
			f.puts "- '"+post+" '"
		}
	end

end