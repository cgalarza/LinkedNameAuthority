module Oracle
  class Employee < OracleDatabase
    self.table_name = 'DARTHR.DC_ACAD_COMMONS_EMP_V'
    self.primary_key = 'netid'

    # Filter out employees with title of Non-Paid, Temporary and nil.    
    scope :valid_title, -> { where.not({ title: ['Temporary', 'Non-Paid', nil] }) }
    
    # Limit to employee records modified after the date given. If date is blank, query is
    # not limited any further.
    scope :modified_since, -> (date) { where('last_modified_date > ?', date) unless date.blank? }

    scope :primary, -> { where({ primary_flag: ['Y', 'y'] }) }
    
    scope :not_primary, -> {
      where('(primary_flag != ? and primary_flag != ?) or primary_flag is null', 'Y', 'y')
    }

    # Return a hash in a connonical form for the Lna Person Loader.
    def to_hash
      unless (self.netid)
        raise ArgumentError.new("#{self.last_name}: No NetID (#{self})")
      end

      # Generate a person's full name.
      nameParts = []
      # See if we have a first name to work with.
      if ((firstname = self.first_name))
        # If there are multiple parts to the first name, work through them.
        if ((firsts = firstname.split(' ')) && firsts.count > 1)
          firsts.each do |part|
            # If true the person has an initial as part of their first
            # name, so we want to append a period to it.
            if (part.length == 1 && part.upcase == part)
              part.concat('.')
            end
          end
          #	Put their first name back together.
          firstname = firsts.join(' ')
        end
      end
      nameParts.push(firstname) if (firstname)
      # The initials field includes the initial of the first name, so we
      # skip it in constructing the full name.
      if (self.initials[1..-1] != '')
        nameParts.push(self.initials[1..-1].split(//).join('.') + '.')
      end
      nameParts.push(self.last_name)
      nameParts.push(self.suffix) if (self.suffix)
      
      # Our full hash.
      {
        netid: self.netid,
        person: {
          given_name:  firstname,
          family_name: self.last_name,
          full_name:   nameParts.join(' '),
          mbox:        self.email,
        },
        membership: {
          primary: (self.primary_flag == 'Y' || self.primary_flag == 'y'),
          title:   self.title,
          org:     {
            label: self.department,
            hr_id: self.department_id.to_s,
          },
          begin_date: self.dept_start_date || self.latest_start_date
        }
      }
    end
  end
end
