class ClassifierClass

require 'rubygems'
require 'yaml'	

	def self.initialize_classifier
		@classifier = Classifier::Bayes.new('Not Spam', 'Spam')

		#spam = YAML::load_file(File.join('public/yaml/', 'spam.yml'))
		#not_spam = YAML::load_file(File.join('public/yaml/', 'not_spam.yml'))

		not_spam = Array.new 
  		sql = "SELECT post FROM favoriteds;"
		favorited_results = ActiveRecord::Base.connection.select_all(sql)

		favorited_results.each do |row|
		 	not_spam << row["post"]
		end

		spam = Array.new 
  		sql = "SELECT post FROM spams;"
		spam_results = ActiveRecord::Base.connection.select_all(sql)

		spam_results.each do |row|
		 	spam << row["post"]
		end

		not_spam.each { |good| @classifier.train_not_spam good }
		spam.each { |spam| @classifier.train_spam spam }
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