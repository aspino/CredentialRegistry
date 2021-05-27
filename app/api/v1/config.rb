require 'entities/envelope_community_config'
require 'entities/envelope_community_config_version'
require 'envelope_community_config'

module API
  module V1
    # Envelope community config API endpoints
    class Config < Grape::API
      helpers CommunityHelpers

      before do
        authenticate!
      end

      route_param :community_name do
        before do
          # params[:envelope_community] =

          @envelope_community = EnvelopeCommunity.find_by!(
            name: select_community
          )
        end

        resources :config do
          desc "Returns the community's config"
          get do
            @envelope_community.config
          end

          desc 'Sets a new config for the community'
          params do
            requires :description, type: String
            requires :payload, type: Hash
          end
          post do
            config = @envelope_community.envelope_community_config ||
                     @envelope_community.build_envelope_community_config

            if config.update(params.slice(:description, :payload))
              status :ok
              present config, with: Entities::EnvelopeCommunityConfig
            else
              status :unprocessable_entity
              { errors: config.errors.full_messages }
            end
          end

          resources :changes do
            desc 'Lists the changes to the config'
            get do
              if (config = @envelope_community.envelope_community_config)
                present config.versions,
                        with: Entities::EnvelopeCommunityConfigVersion
              else
                []
              end
            end
          end
        end
      end
    end
  end
end
