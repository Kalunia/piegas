class ApplicationController < ActionController::Base
	
# Prevent CSRF attacks by raising an exception.
# For APIs, you may want to use :null_session instead.
protect_from_forgery with: :exception

require 'rubygems'

attr_accessor :posts
attr_accessor :product

helper_method :filter

	def txt (str)
		str.sub(" ", "_")
	end

	def filter (str)
		str.sub("%", " ")
		str.sub("|", " ")
		str.sub("@", " ")
		str.sub("'", " ")
		str.sub("\n", " ")
	end

	def wiki (str)
		str.split.map(&:capitalize).join('_')
	end

	private

	def after_sign_in_path_for(resource_or_scope)
    	request.referrer
  	end

  	

end
