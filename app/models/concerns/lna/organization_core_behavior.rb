require 'owl_time'
module Lna
  module OrganizationCoreBehavior
    extend ActiveSupport::Concern
    included do
      has_many :people, class_name: 'Lna::Person', dependent: :restrict,
               as: :primary_org
      has_many :memberships, class_name: 'Lna::Membership', dependent: :destroy
      #predicate: ::RDF::Vocab::ORG.organization

      belongs_to :resulted_from, class_name: 'Lna::Organization::ChangeEvent',
                 predicate: ::RDF::Vocab::ORG.resultedFrom

      validates_presence_of :label #, :begin_date

      type ::RDF::Vocab::ORG.Organization

      property :label, predicate: ::RDF::SKOS.prefLabel, multiple: false do |index|
        index.as :stored_searchable
      end

      property :alt_label, predicate: ::RDF::SKOS.altLabel do |index|
        index.as :stored_searchable
      end

      property :code, predicate: ::RDF::Vocab::ORG.identifier, multiple: false do |index|
        index.as :stored_searchable
      end

      property :begin_date, predicate: Vocabs::OwlTime.hasBeginning, multiple: false do |index|
        index.as :dateable
      end
    end      
  end
end
