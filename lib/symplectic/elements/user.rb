require 'symplectic/elements/publications'

module Symplectic
  module Elements
    class User
      attr_accessor :id, :proprietary_id

      # Creates object from <api:object> element in xml response.
      #
      # @params [Nokogiri::XML::Element] api_object
      def initialize(api_object)
        attri = api_object.attributes
        @id = attri['id'].value
        if p_id = attri['proprietary-id']
          @proprietary_id = p_id.value
        end
      end
      
      # Return a user's publications in 25 publication increments. If page is not specified the
      # results from the first page are returned. Results can be limited by the date they were
      # last modified.
      #
      # @param [DateTime] modified_since filter by date last modified.
      # @param [Integer] page results page to return
      # @return [Array<Symplectic::Elements::Publication>]
      def publications(modified_since: nil, page: 1)
        Symplectic::Elements::Publications.get(modified_since: modified_since,
                                               netid: self.proprietary_id,
                                               page: page)
      end

      # Returns all of a user's publication. Results can be limited by the date they were modified.
      # 
      # @param [DateTime] modified_since filter by date last modified.
      # @return [Array<Symplectic::Elements::Publication>] list of publication objects
      def all_publications(modified_since: nil)
        Symplectic::Elements::Publications.get_all(modified_since: modified_since,
                                                   netid: self.proprietary_id)
      end
      
    end
  end
end
