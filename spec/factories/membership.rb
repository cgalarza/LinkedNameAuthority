FactoryGirl.define do
  factory :thayer_prof, class: Lna::Membership do
    title          'Professor of Engineering'
    email          'mailto:jane.a.doe@dartmouth.edu'
    street_address '14 Engineering Dr.'
    pobox          'HB 0000'
    locality       'Hanover, NH'
    postal_code    '03755'
    country_name   'United States'
    begin_date     Date.today
    end_date       Date.tomorrow
    source         Lna::Membership::SOURCE_MANUAL
    
    association    :organization, factory: :thayer

    # To create less objects, the primary_org of the person is the same
    # as the organization of the membership.
    after(:build) do |prof|
      unless prof.person
        prof.person = FactoryGirl.create(:jane, primary_org: prof.organization)
      end
    end
  end
end
