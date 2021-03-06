class Person::WorksController < ApiController
  before_action :convert_to_full_fedora_id
  
  # GET /person/:person_id/works(/:start_date)
  def index
    @person = search_for_persons(id: params[:person_id]) # throws error if we can't find the person
    
    start_date = params[:start_date] || nil
    
    @works = search_for_works(
      collection_id: @person['collection_id_ssi'],
      start_date: start_date,
      sort: 'date_dtsi desc'
    )

    respond_to do |f|
      f.jsonld { render :index, content_type: 'application/ld+json' }
    end
  end

  # GET /person/:person_id/works/feed
  def feed
    @person = search_for_persons(id: params[:person_id])
    @works = search_for_works(collection_id: @person['collection_id_ssi'], sort: 'date_dtsi desc')

    respond_to do |f|
      f.atom
      f.all {render 'feed.atom.builder', content_type: 'application/atom+xml'}
    end
  end
end
