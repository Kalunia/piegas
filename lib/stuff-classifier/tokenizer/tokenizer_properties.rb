# encoding: utf-8
require 'set'
StuffClassifier::Tokenizer::TOKENIZER_PROPERTIES = {
  "pt" => {
    :stop_word => Set.new([
     'a', 'à', 'acerca', 'agora', 'alguns', 'algum', 'algumas', 'às','ao', 'aos', 'as', 'ate', 'até', 'ateh', 
     'com', 'como', 
     'da', 'das', 'de', 'dele', 'deles', 'depois', 'do', 'dos', 
     'e', 'é', 'eh', 'ela', 'elas', 'ele', 'eles', 'em', 'enquanto', 'entre', 'era', 'essa', 'essas', 'esse', 'esses', 'este', 'estes', 'está', 'estão', 'eu', 
     'foi', 'foram', 'fosse',
     'há', 'havia', 'horas', 
     'inicio', 'ir', 'isso', 'isto',
     'já', 
     'lhe', 
     'mas', 'mais', 'maioria', 'me', 'mesmo', 'meu', 'minha', 'muito', 
     'na', 'nao', 'não', 'naum', 'nas', 'nem', 'no', 'nois', 'nós', 'nos', 'nosso', 'num', 'numa', 
     'o', 'os', 'ou', 
     'pa', 'para', 'parte', 'pela', 'pelas', 'pelo', 'pelos', 'pode', 'por', 'porque', 'povo',
     'qual', 'quando', 'que', 'quem', 
     'são', 'se', 'seja', 'sem', 'ser', 'será', 'seu', 'seus', 'só', 'soh', 'somente', 'sua', 'suas', 
     'tambem', 'também', 'tem', 'têm', 'tempo', 'tenho', 'tentar', 'ter', 'tinha', 'tmb', 'to', 'todo', 'todos', 'tu',
     'último', 'ultimo', 'um', 'uma', 'uns', 'usa', 'usar',
     'ver', 'veja', 'verdade', 'verdadeiro', 'vc', 'voce', 'você'            
    ])
  }
}