require 'sinatra/base'
module Tmbundle
  module Manager
    class Server < Sinatra::Base
      get '/api/v1/bundles' do
        [
          {
            name: 'elia/avian-missing',
            git: 'https://github.com/elia/avian-missing.git'
          },
          {
            name: 'elia/markdown-redcarpet',
            git: 'https://github.com/elia/markdown-redcarpet.git'
          },
        ].to_yaml
      end
    end
  end
end
