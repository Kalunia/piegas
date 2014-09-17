# Este código foi extraido em grande parte através do GitHUB https://github.com/alexandru/stuff-classifier
# e adaptado por Pedro Grandin

# encoding: utf-8

require "stemmerportuguese"

class StuffClassifier::Tokenizer
  require  "stuff-classifier/tokenizer/tokenizer_properties"
  
  # Inicialização do tokenizer
  def initialize(opts={})
    @language = "pt"
    @properties = StuffClassifier::Tokenizer::TOKENIZER_PROPERTIES[@language]
    
    @stemming = true
    if @stemming
      @stemmer = StemmerPortuguese.new
    end
  end

  def language
    @language
  end

  def ignore_word(value)
    @ignore_words.add(value)
  end

  def ignore_words
    @ignore_words || @properties[:stop_word]
  end

  def stemming?
    @stemming || false
  end

  # Recorre cada palavra, separando e organizando
  def each_word(string)
    string = string.strip
    return if string == ''

    words = []

    # tokenize string
    string.split("\n").each do |line|

      line.gsub(/\p{Word}+/).each do |w|
          next if w == '' || ignore_words.member?(w.downcase)

        if stemming? and stemable?(w)
          #puts "Stem - "+w+" = "+@stemmer.stem(w).downcase
          #puts ""
          w = @stemmer.stem(w).downcase
          #puts w
          next if ignore_words.member?(w)
        else
          w = w.downcase
        end

        words << (block_given? ? (yield w) : w)
      end
    end

    return words
  end

  # Recorre cada palavra, separando e organizando
  def each_word_tag_cloud(string)
    string = string.strip
    return if string == ''

    words = ""

    # tokenize string
    string.split("\n").each do |line|

      line.gsub(/\p{Word}+/).each do |w|
          next if w == '' || ignore_words.member?(w.downcase)

        words += " " + (block_given? ? (yield w) : w).downcase
      end
    end

    return words
  end

private 

  def stemable?(word)
    word =~ /^\p{Alpha}+$/
  end
  
end
