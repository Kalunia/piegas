class ResultsController < ApplicationController
 
	def index
		Prawn::Document.generate("hello.pdf") do
		  text "Hello World!"
		end
	end

end
