# encoding: utf-8

require 'set'

StuffClassifier::Filter = {
    :trash_word => Set.new([
     '=)', '=P', '=p', '=*', '=D', '=]', '=[', '=(', ':)', ':(', ':]', ':[', ':P', ':p', ':*', 'T.T', '^^',
     '.com', '.br',
     'ish',
     ' vish',
     'lol', 'LOL', 'Lol'
    ])
}