# Este código foi extraido em grande parte através do GitHUB https://github.com/alexandru/stuff-classifier
# e adaptado por Pedro Grandin

# encoding: utf-8

class StuffClassifier::Base
  extend StuffClassifier::Storage::ActAsStorable
  require  "stuff-classifier/filter"

  attr_reader :name
  attr_reader :word_list
  attr_reader :category_list
  attr_reader :training_count

  attr_accessor :tokenizer
  attr_accessor :language
  
  attr_accessor :thresholds
  attr_accessor :min_prob


  storable :version,:word_list,:category_list,:training_count,:thresholds,:min_prob

  # Inicializa a base do classificador
  def initialize(name, opts={})
    #@version = StuffClassifier::VERSION

    @name = name

    @word_list = {}
    @category_list = {}
    @training_count=0

    # Repositório
    purge_state = opts[:purge_state]
    @storage = opts[:storage] || StuffClassifier::Base.storage
    unless purge_state
      @storage.load_state(self)
    else
      @storage.purge_state(self)
    end

    @thresholds = opts[:thresholds] || {}
    @min_prob = opts[:min_prob] || 0.0

    @ignore_words = nil
    @tokenizer = StuffClassifier::Tokenizer.new(opts)

    @filter = StuffClassifier::Filter[:trash_word]
    
  end

  # Incrementa palavra à categoria indicada
  def incr_word(word, category)
    @word_list[word] ||= {}

    @word_list[word][:categories] ||= {}
    @word_list[word][:categories][category] ||= 0
    @word_list[word][:categories][category] += 1

    @word_list[word][:_total_word] ||= 0
    @word_list[word][:_total_word] += 1

    @category_list[category] ||= {}
    @category_list[category][:_total_word] ||= 0
    @category_list[category][:_total_word] += 1

  end

  # Incrementa categoria
  def incr_cat(category)
    @category_list[category] ||= {}
    @category_list[category][:_count] ||= 0
    @category_list[category][:_count] += 1

    @training_count ||= 0
    @training_count += 1 

  end

  # Retorna o número de vezes que a palavra aparece na categoria indicada
  def word_count(word, category)
    return 0.0 unless @word_list[word] && @word_list[word][:categories] && @word_list[word][:categories][category]
    @word_list[word][:categories][category].to_f
  end

  # Retorna o número de vezes que a palavra aparece em todas as categorias
  def total_word_count(word)
    return 0.0 unless @word_list[word] && @word_list[word][:_total_word]
    @word_list[word][:_total_word].to_f
  end

  # Retorna o número de palavras da uma categoria
  def total_word_count_in_cat(cat)
    return 0.0 unless @category_list[cat] && @category_list[cat][:_total_word]
    @category_list[cat][:_total_word].to_f
  end

  # Retorn o número de itens em treinamento 
  def total_cat_count
    @training_count
  end
  
  # Retorna o numero de documentos treinados pela categoria
  def cat_count(category)
    @category_list[category][:_count] ? @category_list[category][:_count].to_f : 0.0
  end

  # Retorna as palavras da categoria
  def cat_words
    return  @word_list
  end

  # Retorna o número de vezes que a palavra aparece nas categorias
    def categories_with_word_count(word)
    return 0 unless @word_list[word] && @word_list[word][:categories]
    @word_list[word][:categories].length 
  end  

  # Retorna o número de categorias
  def total_categories
    categories.length
  end

  # Retorna a lista de categorias
  def categories
    @category_list.keys
  end

  # Treina a categoria com o texto indicado
  def train(category, text)
    @tokenizer.each_word(text) {|w| incr_word(w, category) }
    #puts(category)
    #puts "------------------------------------"
    incr_cat(category)
  end

  # Treina os Tweets negativos
  def train_negative()
    File.open("public/tweets-negatives.txt", "r").each_line do |line|
      train("negative", filter(line))
    end
  end

  #Treina os Tweets positivos
  def train_positive()
    File.open("public/tweets-positives.txt", "r").each_line do |line|
      train("positive", filter(line))
    end
  end

  #Filtra o tweet com palavras inutilizadas 
  def filter(text)

    #Remove palavras inutilizaveis
    @filter.each do |trash_word|
      text.gsub! /\b#{trash_word}\b/i, ''
    end

    #Remove Links HTTPS
    text = text.gsub /https?:\/\/[\S]+/i, ''

    #Remove Links HTTP
    text = text.gsub /http?:\/\/[\S]+/i, ''

    # Remove tudo que é caracter inválido
    text.encode('UTF-8', :invalid => :replace, :undef => :replace)

    #Remove risadas "sauhsauhsua", "hahaha", "hehehe" 
    text = text.gsub(/\b[hsuae]+\b/i, '')

    #Remove risadas "rsrsrs"
    text = text.gsub(/\b[rs]+\b/i, '')

    #Remove hashtags
    #text = text.gsub /(?:\s|^)(?:#(?!(?:\d+|\w+?_|_\w+?)(?:\s|$)))(\w+)(?=\s|$)/i, ''
    text = text.gsub /#/, ''

    #Remove @usuario
    text = text.gsub /(?:\s|^)(?:@(?!(?:\d+|\w+?_|_\w+?)(?:\s|$)))(\w+)(?=\s|$)/i, ''

    # Remove numeros
    text = text.gsub /(W|\d)/, ''
   
    #Remove caracteres repetidos
    text = text.squeeze

    #puts text
    return text
  end

  # Classifica o texto
  def classify(text, default="neutro")
    # Find the category with the highest probability
    max_prob = @min_prob
    best = nil

    scores = cat_scores(text)
    scores.each do |score|
      cat, prob = score
       #puts cat+": "+prob.to_s

      if prob > max_prob
        max_prob = prob
        best = cat
      end
    end

    return default unless best

    threshold = @thresholds[best] || 1.3

    scores.each do |score|
      cat, prob = score
      next if cat == best
      return default if prob * threshold > max_prob
    end

    return best
  end


  def classify_tagword(word)

    sentiment = classify(word)

    if sentiment.include?('positive')
      return 'green'
    elsif  sentiment.include?('negative')
      return 'red'
    elsif sentiment.include?('neutro')
      return 'gray'
    end
  end

  # Salva estado atual do classificador
  def save_state
    @storage.save_state(self)
  end

  class << self
    attr_writer :storage

    def storage
      @storage = StuffClassifier::InMemoryStorage.new unless defined? @storage
      @storage
    end

    def open(name)
      inst = self.new(name)
      if block_given?
        yield inst
        inst.save_state
      else
        inst
      end
    end
  end
end
