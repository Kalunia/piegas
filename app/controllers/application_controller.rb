class ApplicationController < ActionController::Base
	
# Prevent CSRF attacks by raising an exception.
# For APIs, you may want to use :null_session instead.
protect_from_forgery with: :exception

require 'rubygems'

attr_accessor :posts
attr_accessor :product

	def txt (str)
		str.sub(" ", "_")
	end

	def filter (str)
		str.sub("%", " ")
		str.sub("|", " ")
		str.sub("@", " ")
	end

	def wiki (str)
		str.split.map(&:capitalize).join('_')
	end

end
