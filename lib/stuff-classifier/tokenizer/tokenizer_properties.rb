# Este código foi inspirado através do GitHUB https://github.com/alexandru/stuff-classifier
# e adaptado por Pedro Grandin

# encoding: utf-8

require 'set'
StuffClassifier::Tokenizer::TOKENIZER_PROPERTIES = {
  "pt" => {
    :stop_word => Set.new([
     'a', 'à', 'acerca', 'agora', 'alguns', 'algum', 'algumas', 'às','ao', 'aos', 'as', 'asim', 'assim', 'ate', 'até', 'ateh', 
     'c', 'cima', 'cmg', 'co', 'com', 'como', 
     'd', 'da', 'das', 'de', 'dela', 'delas', 'dele', 'deles', 'depois', 'deverá', 'devera', 'do', 'dos', 'du', 'dus', 
     'e', 'e', 'é', 'eh', 'ela', 'elas', 'ele', 'eles', 'em', 'enquanto', 'entre', 'era', 'eram', 'essa', 'esa', 'essas', 'esas', ' esse', 'ese', 'esses', 'eses', 'este', 'estes', 'está', 'estao', 'estão', 'estava', 'estavam', 'estou', 'eu', 
     'f', 'falei', 'falaram', 'falou', 'fica', 'fico', 'ficam', 'ficaram', 'foi', 'foram', 'fosse', 
     'h', 'há', 'havia', 'horas',
     'i', 'ia', 'ir', 'isso', 'isto',
     'j', 'ja', 'já', 'jah',
     'k',
     'l', 'lhe',
     'm', 'mai', 'mas', 'mais', 'maioria', 'me', 'mesmo', 'meu', 'minha', 'mt', 'mto', 'muito', 
     'na', 'nas', 'no', 'nois', 'nós', 'nos', 'noso', 'nosso', 'num', 'numa', 
     'o', 'os', 'ou', 
     'p', 'pa', 'para', 'parte', 'pela', 'pelas', 'pelo', 'pelos', 'pode', 'pois', 'por', 'porque', 'povo', 'pq', 'pra',
     'q', 'qual', 'quando', 'que', 'quem', 'queria', 'quero', 
     's', 'sao', 'são', 'se', 'seja', 'sem', 'ser', 'será', 'seu', 'seus', 'só', 'soh', 'somente', 'sua', 'suas', 
     't', 'tambem', 'também', 'tão', 'tem', 'têm', 'tempo', 'tenho', 'tentar', 'ter', 'tinha', 'tmb', 'to', 'tou', 'todo', 'todos', 'tu',
     'u', 'último', 'ultimo', 'um', 'uma', 'uns', 'usa', 'usar',
     'x',
     'v', 'vai', 'vem', 'ver', 'veja', 'verdade', 'verdadeiro', 'vc', 'voce', 'você', 'vs'          
    ]),
    :negation_word => Set.new([
     'n', 'ñ', 'nao', 'não', 'naum', 'nem', 'not',
      'sem'
    ])
  }
}