# encoding: utf-8

require 'set'

StuffClassifier::Filter = {
    :trash_word => Set.new([
     '=)', '=P', '=p', '=*', '=D', '=]', '=[', '=(', ':)', ':(', ':]', ':[', ':P', ':p', ':*', 'T.T', '^^',
     'caramba',
     'eita',
     'ish',
     'ne', 'né', 'neh',
     'vish',
     'lol', 'LOL', 'Lol',
     'menino', 'menina', 'homem', 'mulher',
     'amanha', 'amanhã', 'ontem',
     'manhã', 'tarde', 'noite', 
     'um', 'dois', 'tres', 'três', 'quatro', 'cinco', 'seis', 'sete', 'oito', 'nove', 'dez'
    ])
}