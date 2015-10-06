module DateHelper
  def date_setter(name, d)
    case d.class.name
    when 'RDF::Literal::Date'
      value = d
    when 'String'
      begin
        value = ::RDF::Literal.new(Date.parse(d))
      rescue
        raise ArgumentError, "#{name} could not be converted to a date."
      end
    when 'Date', 'DateTime', 'Time'  
      value = ::RDF::Literal.new(Date.parse(d.to_s))
    else
      raise ArgumentError, "#{name} cannot be a #{d.class}."
    end
    
    set_value(name, value)  
  end
end
