class OrganizationController < CrudController
  before_action :convert_sub_and_super_org_ids, only: [:create, :update]
  
  PARAM_TO_MODEL = {
    'org:identifier'         => 'code',
    'skos:pref_label'        => 'label',
    'skos:alt_label'         => 'alt_label',
    'owltime:hasBeginning'   => 'begin_date',
    'org:hasSubOrganization' => 'sub_organization_ids', #{application_url}/organization/{id}
    'org:subOrganizationOf'  => 'super_organization_ids'
  }.freeze
  # historic organization don't have sub and super or accounts

  # GET /organization/:id
  def show
    @organization = search_for_organizations(id: params[:id])
    
    ids = ['subOrganizationOf_ssim',
           'hasSubOrganization_ssim'].map{ |i| @organization[i] }.compact.flatten
    @related_orgs = search_for_ids(ids)

    @accounts = search_for_accounts(person_id: @organization['id'])

    ids = ['resultedFrom_ssim', 'changedBy_ssim'].map{ |i| @organization[i] }.compact.flatten
    @change_events = search_for_ids(ids)
    
    super
  end

  # POST /organization
  def create
    # Create organization
    attributes = params_to_attributes(organization_params)
    o = Lna::Organization.new(attributes)
    render_unprocessable_entity && return unless p.save

    @organization = search_for_id(o.id)

    location = organization_path(id: FedoraID.shorten(o.id))

    respond_to do |f|
      f.jsonld { render :create, status: :created, location: location,
                        content_type: 'application/ld+json'}
    end
  end

  # PUT /organization/:id
  def update
    organization = search_for_organization(id: params[:id])

    # Update organization (could be historic or active)
    o = ActiveFedora::Base.find(organization['id'])
    if o.class == Lna::Organization
      attributes = params_to_attributes(organization_params, put: true
                                        sub_organization_ids: params['org:hasSubOrganization'],
                                        super_organization_ids: params['org:subOrganizationOf'])
    else
      attributes = params_to_attributes(organization_params, put: true)
    end
    render_unprocessable_entity && return unless p.update(attributes)

    @organization = search_for_organization(id: organization['id'])
    
    super
  end

  # DELETE /organization/:id
  def destroy
    o = search_for_organizations(id: params[:id])

    # Delete organization
    organization = ActiveFedora::Base.find(o['id'])
    organization.destroy
    render_unprocessable_entity && return unless organization.destroyed?
   
    super
  end

  private

  def organization_params
    params.permit(PARAM_TO_MODEL.keys.concat(['id', 'org:hasSubOrganization', 'org:subOrganizationOf']))
  end
end

  