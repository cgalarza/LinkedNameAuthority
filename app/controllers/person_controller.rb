class PersonController < ApiController
  before_action :convert_to_full_fedora_id, except: :create
  before_action :convert_org_to_fedora_id
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  PARAM_TO_MODEL = {
      'foaf:name'       => 'full_name',
      'foaf:givenName'  => 'given_name',
      'foaf:familyName' => 'family_name',
      'foaf:title'      => 'title',
      'foaf:mbox'       => 'mbox',
      'foaf:image'      => 'image',
      'foaf:homepage'   => 'homepage',
      'org:reportsTo'   => 'primary_org_id'
  }.freeze
  
  # GET /person(/:id)
  def show
    @person = search_for_persons(id: params[:id])
    @memberships = search_for_memberships(person_id: @person['id'])
    @accounts = search_for_accounts(person_id: @person['id'])

    # primary organization and all the membership's organizations
    org_ids = [ @person['reportsTo_ssim'].first ]
    @memberships.each do |m|
      org_ids << m['Organization_ssim'].first
    end

    query = ActiveFedora::SolrQueryBuilder.construct_query_for_ids(org_ids.uniq)
    @organizations = ActiveFedora::SolrService.query(query)

    respond_to do |format|
      format.jsonld { render :show, content_type: 'application/ld+json' }
      format.html
    end
  end

  # POST /person
  def create
    attributes = {}
    PARAM_TO_MODEL.select { |f, _| person_params[f] }.each do |f, v|
      attributes[v] = person_params[f]
    end
    
    p = Lna::Person.create!(attributes)
    
    @person = search_for_id(p.id)

    location = "/person/#{FedoraID.shorten(p.id)}"
    
    respond_to do |format|
      format.jsonld { render :create, status: :created, location: location, content_type: 'application/ld+json' }
    end
  end

  # PUT /person/:id
  def update
    person = search_for_persons(id: params[:id])
    
    attributes = {}
    PARAM_TO_MODEL.each do |f, v|
      attributes[v] = person_params[f] || nil
    end

    Lna::Person.find(person['id']).update(attributes)

    # What should happen if it doesn't work.
    
    @person = search_for_persons(id: params[:id])

    respond_to do |f|
      f.jsonld { render :create, content_type: 'application/ld+json' }
    end    
  end

  # DELETE /person/:id
  def destroy
    p = search_for_persons(id: params[:id])

    # Delete person
    Lna::Person.find(p['id']).destroy

    # What happens if it doesnt work?
    
    respond_to do |f|
      f.jsonld { render json: '{"status": "success"}', content_type: 'application/ld+json' }
    end
  end

  private

  def convert_org_to_fedora_id
    params['org:reportsTo'] = org_uri_to_fedora_id(params['org:reportsTo'])
  end
  
  def person_params
    params.permit(PARAM_TO_MODEL.keys)
  end
end
