require 'spec_helper'

describe 'layers' do
  describe 'GET /' do
    it 'works!' do
      visit '/'
      page.driver.response.status.should be(200)
    end
  end
end
