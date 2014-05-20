class ApplicationController < ActionController::Base

require 'rubygems'


	def txt (str)
		str.sub(" ", "_")
	end


	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
end
