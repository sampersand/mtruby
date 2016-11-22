require './formats'
require './card'

class Board < Hash
	attr_reader :type
	alias :parent_length :length
	alias :name :type
	def initialize type, board
		super(board)
		@type = type
		raise Exception if type != :MB and type != :SB
		merge! board
	end
	def to_s
		"#{@type}: #{super}"
	end

	def length
		res = 0
		each {|_, (_, amnt)| res += amnt}
		res
	end
	alias :size :length

	def boardlist
		ret = []
		each do |_cardname, (card, amnt)|
			ret << "#{@type}: #{amnt} #{card}"
		end
		ret
	end
end

class Deck
	def initialize mainb, sideb, *, formats:, name:, check: true
		@mainb = Board.new :MB, mainb
		@sideb = Board.new :SB, sideb
		@name = name
		@formats = formats
		check = false
		@formats.all? {|format| format.assert_valid self} if check
	end

	attr_reader :formats
	attr_reader :name
	attr_reader :mainb
	attr_reader :sideb
	alias :MB :mainb
	alias :SB :sideb
	alias :to_s :name

	def decklist
		["DECK: #{name}", "FMTS: #{formats}", mainb.boardlist, sideb.boardlist]
	end
	alias :to_decklist :decklist

	class << self
		class NoDeckFound < ArgumentError; end

		def from mainb_names, sideb_names, **kwargs
			mainb = {}
			sideb = {}
			mainb_names.each {|name, amnt| mainb[name] = [Card.new(name), amnt] }
			sideb_names.each {|name, amnt| sideb[name] = [Card.new(name), amnt] }
			Deck.new mainb, sideb, **kwargs
		end
		def from_url url, **kwargs, &block
			begin
				from *block.call(open(url){|f| f.read}), **kwargs
			rescue OpenURI::HTTPError => e
				if e.io.status[0] == '404'
					raise NoDeckFound.new "No deck found at url '#{url}'."
				end
				raise e
			end
		end
		def from_decklist decklist
			mainb = {}
			sideb = {}
			# deckname = deckname.match /(?m)^== '(.*)' ==$/
			# mainboard = decklist.match /(?m)^== '(.*)' ==$/
			lines = decklist.lines
			# puts mainboard
			decklist.lines.each{ |card_data|
				if card_data != "\n"
					board_toadd = mainb
					if card_data =~ /^SB/
						card_data = card_data.gsub /SB: */, ''
						board_toadd = sideb
					end
					amount, name = card_data.split ' ', 2
					board_toadd[name[0, name.length - 1]] = amount.to_i
				end
				# board_toadd = mainb
				# if card_data =~ /^S/
				# 	card_data = card_data.gsub /SB: */, ''
				# 	board_toadd = sideb

				# end
				# amount, name = card_data.split ' ', 2
				# board_toadd[name] = amount.to_i
			}
			formats = [Standard]
			name = 'name'
			Deck.new mainb, sideb, formats: formats, name: name
			[mainb, sideb]
		end
	end
end

class Deck
	class << self
		def from_tapped_out_deck deck_id, **kwargs
			url = "http://tappedout.net/mtg-decks/#{deck_id}/?fmt=dec"
			from_url(url, **kwargs){|deck_data|
				# deck_data.insert 0, "== '#{kwargs[:name]}' ==\n" #add in name
				from_decklist deck_data
			}
		end
	end
end

d = Deck.from_tapped_out_deck('15-11-16-kOX-rw-vehicles', name: 'RW Vehicles', formats: [Standard])
require 'pp'
pp d.decklist
puts d.sideb.size
# puts Deck.from_decklist(d.decklist.join "\n")














