require 'spec_helper'

describe 'user_geo_edits' do
  describe 'GET /' do
    it 'works!' do
      visit '/'
      page.driver.response.status.should be(200)
    end
  end
end
