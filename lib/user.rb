module UserInternal
  class OrganizationRecord
    attr_reader :name, :slug

    def initialize(raw_data)
      @name = raw_data['name']
      @slug = raw_data['slug']
    end
  end

  class UserRecord
    attr_reader :first_name, :last_name, :full_name, :organizations, :primary_organization

    def initialize(raw_data)
      @first_name = raw_data['first_name']
      @last_name = raw_data['last_name']
      @full_name = raw_data['full_name']
      @organizations = raw_data['organizations'].map do |org|
        OrganizationRecord.new(org)
      end
      @primary_organization = @organizations.first
    end
  end
end

module User
  include UserInternal

  def fetch(uuid, app_secret)
    @app_secret = app_secret
    @api_base_url = ENV['LIVESTAX_API_URL']
    user_data = get_user(user_api_uri(uuid))
    UserRecord.new(user_data)
  end

  def user_api_uri(uuid)
    URI("#{@api_base_url}/user/#{uuid}")
  end

  def get_user(uri)
    response = Net::HTTP.new(uri.host, uri.port).start do |http|
      http.request(build_request(uri))
    end
    JSON.parse(response.body)
  end

  def build_request(uri)
    req = Net::HTTP::Get.new(uri.path)
    req.add_field("Authorization", "Bearer #{@app_secret}")
    req
  end

  module_function :fetch, :user_api_uri, :get_user, :build_request
  private_class_method :user_api_uri, :get_user, :build_request
end
