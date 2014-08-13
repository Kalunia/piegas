# encoding: utf-8

class StuffClassifier::Bayes < StuffClassifier::Base
  attr_accessor :weight
  attr_accessor :assumed_prob

  extend StuffClassifier::Storage::ActAsStorable
  storable :weight,:assumed_prob

  # Inicializa Naive Bayes
  def initialize(name, opts={})
    super(name, opts)
    @weight = opts[:weight] || 1.0
    @assumed_prob = opts[:assumed_prob] || 0.1
  end

  # Define a probabilidade da palavra na categoria indicada
  def word_prob(word, cat)
    total_words_in_cat = total_word_count_in_cat(cat)
    return 0.0 if total_words_in_cat == 0
    word_count(word, cat).to_f / total_words_in_cat
  end

  # Calcula a probabilidade média da palavra na categoria indicada
  def word_weighted_average(word, cat, opts={})
    func = opts[:func]

    # Calcula a probabilidade atual
    basic_prob = func ? func.call(word, cat) : word_prob(word, cat)
    
    # Conta o número de vezes que a palavra aparece em todas as categorias
    totals = total_word_count(word)
    
    # Média total
    (@weight * @assumed_prob + totals * basic_prob) / (@weight + totals)
  end

  # Calcula a probabilidade de cada palavra em um determinado texto
  def doc_prob(text, category)
    @tokenizer.each_word(text).map {|w|
      word_weighted_average(w, category)
    }.inject(1) {|p,c| p * c}
  end

  # Calcula a probabilidade do texto na categoria indicada
  def text_prob(text, category)
    cat_prob = cat_count(category) / total_cat_count
    doc_prob = doc_prob(text, category)
    cat_prob * doc_prob
  end

  # Define as probabilidades do texto para cada categoria
  def cat_scores(text)
    probs = {}
    categories.each do |cat|
      probs[cat] = text_prob(text, cat)
    end
    probs.map{|k,v| [k,v]}.sort{|a,b| b[1] <=> a[1]}
  end

  # Mostra os detalhes da classificação da palavra
  def word_classification_detail(word)

    p "word_prob"
    result=self.categories.inject({}) do |h,cat| h[cat]=self.word_prob(word,cat);h end
    p result

    p "word_weighted_average"
    result=categories.inject({}) do |h,cat| h[cat]=word_weighted_average(word,cat);h end  
    p result

    p "doc_prob"
    result=categories.inject({}) do |h,cat| h[cat]=doc_prob(word,cat);h end  
    p result

    p "text_prob"
    result=categories.inject({}) do |h,cat| h[cat]=text_prob(word,cat);h end  
    p result
    
  end

end
