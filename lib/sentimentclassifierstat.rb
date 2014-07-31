# require 'helper'

# class Start < TestBase
# 	before do

# 		StuffClassifier::Base.storage = StuffClassifier::InMemoryStorage.new

# 		StuffClassifier::Bayes.open("Positive vs Negative") do |cls|
# 		    cls.train_positive()
# 		    cls.train_negative()
# 		end
# 	end
# end