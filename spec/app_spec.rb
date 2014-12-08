require_relative 'spec_helper'
require_relative 'support/story_helpers'
require 'json'

describe 'TeamPay Stories' do
  include StoryHelpers

  describe 'Getting the root of the TeamPay Service' do
    it 'Should return ok' do
      get '/'
      last_response.must_be :ok?
    end
  end  
end
