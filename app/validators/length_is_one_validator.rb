class LengthIsOneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.size != 1
      record.errors.add(attribute, 'length must be one.')
    end
  end
end
