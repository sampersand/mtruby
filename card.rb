class AbstractCard
	private
	def initialize
		if self.class == AbstractCard
			raise "Cannot initialize type #{self.class}"
		end
	end

	public
	def to_s
		name.to_s
	end

	def alltypes
		[supertypes, types, subtypes]
	end

	def pt
		power.nil? ? nil : [power, toughness]
	end

end

class Card < AbstractCard
	private
		def initialize(id)
			@id = id
		end
		def self.query_attr(attribute)
			define_method(attribute, ->(){ @details[attribute] })
		end
	public
		def == other
			eql? other || name == other.to_sym || name == other.to_s.to_sym
		end

		def hash; @details.hash end
		def to_s; name.to_s end
		def alltypes; [supertypes, types, subtypes] end
		def pt; power.nil? ? nil : [power, toughness] end

		def values
			@details
		end
		

		query_attr :power
		query_attr :toughness
		query_attr :name
		query_attr :id
		query_attr :supertypes
		query_attr :types
		query_attr :colors
		query_attr :cmc
		query_attr :cost
		query_attr :text
		query_attr :formats
		query_attr :subtypes

		attr_reader :details
		alias :inspect :values
end


















