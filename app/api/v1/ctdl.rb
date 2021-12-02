require 'run_ctdl_query'

module API
  module V1
    # CTDL endpoint
    class Ctdl < MountableAPI
      mounted do
        helpers CommunityHelpers
        helpers SharedHelpers

        before do
          authenticate!
        end

        desc 'Executes a CTDL query'
        params do
          optional :debug, default: false, type: Grape::API::Boolean
          optional :include_description_set_resources, default: false, type: Grape::API::Boolean
          optional :include_description_sets, default: false, type: Grape::API::Boolean
          optional :include_graph_data, default: false, type: Grape::API::Boolean
          optional :include_results_metadata, default: false, type: Grape::API::Boolean
          optional :log, default: true, type: Grape::API::Boolean
          optional :order_by, default: '^search:relevance', type: String
          optional :per_branch_limit, type: Integer
          optional :skip, default: 0, type: Integer
          optional :take, default: 10, type: Integer
        end
        post '/ctdl' do
          query = JSON(request.body.read)
          request.body.rewind

          options = params.slice(
            :debug,
            :include_description_set_resources,
            :include_description_sets,
            :include_graph_data,
            :include_results_metadata,
            :log,
            :order_by,
            :per_branch_limit,
            :skip,
            :take
          )

          response = RunCtdlQuery.call(
            query,
            envelope_community: EnvelopeCommunity.find_by!(name: select_community),
            **options.symbolize_keys
          )

          status response.status
          response.result
        end
      end
    end
  end
end
