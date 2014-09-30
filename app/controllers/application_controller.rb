class ApplicationController < ActionController::Base
	
# Prevent CSRF attacks by raising an exception.
# For APIs, you may want to use :null_session instead.
protect_from_forgery with: :exception

require 'rubygems'
require 'set'

attr_accessor :posts
attr_accessor :product

helper_method :filter

before_action :configure_permitted_parameters, if: :devise_controller?
	
	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:account_update) << :anti_spam
	end
	

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

	#Filtra o tweet com palavras inutilizadas 
	def filter_tweet(text, query)

		@filter = StuffClassifier::Filter[:trash_word]
		
	    #Remove palavras inutilizaveis
	    @filter.each do |trash_word|
	      text.gsub! /\b#{trash_word}\b/i, ''
	    end

	    # Remove tudo que é caracter inválido (ex: emoticons)
	    text.encode('UTF-8', :invalid => :replace, :undef => :replace)

	    # Remove o query
	    text.gsub!(/#{query}/i, '')

	    #Remove risadas "sauhsauhsua", "hahaha", "hehehe" 
	    text = text.gsub(/\b[hsuae]+\b/i, '')

	    #Remove risadas "rsrsrs"
	    text = text.gsub(/\b[rs]+\b/i, '')

	    #Remove #hashtags
	    #text = text.gsub /(?:\s|^)(?:#(?!(?:\d+|\w+?_|_\w+?)(?:\s|$)))(\w+)(?=\s|$)/i, ''
	    text = text.gsub /#/, ''

	    #Remove @usuario
	    text = text.gsub /(?:\s|^)(?:@(?!(?:\d+|\w+?_|_\w+?)(?:\s|$)))(\w+)(?=\s|$)/i, ''
	   
	    # Remove numeros
	    text = text.gsub /(W|\d)/, ''
	   
	    #Remove caracteres repetidos
	    text = text.squeeze

	   	# Remove saudações
	    text = text.gsub /bom dia/i, ''
	    text = text.gsub /boa tarde/i, ''
	    text = text.gsub /boa noite/i, ''

	    puts text || ""

	    return text unless text == nil
  	end

	private

	# def after_sign_in_path_for(resource_or_scope)
 #    	request.referrer
 #  	end

  	

end
