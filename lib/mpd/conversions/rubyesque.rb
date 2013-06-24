transform(:boolean) { |value| value && value.to_i > 0 }
transform(:float)   { |value| value == 'nan' ? Float::NAN : Float(value) }
transform(:symbol)  { |value| value && value.to_sym }

conversion :repeat, :random, :consume, :single, :xfade, :to => :boolean
conversion :mixrampdelay, :mixrampdb, :to => :float
conversion :state, :to => :symbol
ignore :title, :artist, :album_artist
