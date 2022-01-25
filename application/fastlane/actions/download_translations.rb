module Fastlane
  module Actions
    class DownloadTranslationsAction < Action
      def self.run(params)
        require "net/http"
        require "uri"
        require "json"

        api_token = params[:api_token]
        project_id = params[:project_id]
        languages = params[:languages]
        output_dir = params[:output_dir]
        output_template = params[:output_template] # "translation_%s.i18n.yaml"
        type = params[:type]
        filters = params[:filters]

        destination_path = File.expand_path(output_dir.shellescape)
        dirname = File.dirname(destination_path)
        unless File.directory?(dirname)
          FileUtils.mkdir_p(dirname)
        end

        for language in languages
          UI.important "⏬  Downloading #{language} to #{destination_path}..."
          begin
            uri = URI.parse("https://api.poeditor.com/v2/projects/export")
            request = Net::HTTP::Post.new(uri)
            request.set_form_data(
              "api_token" => api_token,
              # translated', 'untranslated', 'fuzzy', 'not_fuzzy', 'automatic', 'not_automatic', 'proofread', 'not_proofread'
              "filters" => filters.reduce{ |v, s| "#{v},#{s}"},
              "id" => project_id,
              "language" => language,
              "type" => type,
            )

            req_options = {
              use_ssl: uri.scheme == "https",
            }

            response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
              http.request(request)
            end

            download_url = JSON.parse(response.body)["result"]["url"]

            uri = URI.parse(download_url)
            response = Net::HTTP.get_response(uri)
            fileName = output_template % [language]
            filePath = "#{destination_path}/#{fileName}"

            File.write(filePath, response.body, mode: "w")
            UI.important "✅ Saved #{filePath}"
          rescue => ex
            UI.user_error!("Error fetching remote file: #{ex}")
          end
        end

        # sh "shellcommand ./path"

        # Actions.lane_context[SharedValues::DOWNLOAD_TRANSLATIONS_CUSTOM_VALUE] = "my_val"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Download PoEditor translations."
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :api_token,
            env_name: "POEDITOR_API_TOKEN",
            description: "POEditor API Token",
            type: String,
            optional: false,
          ),
          FastlaneCore::ConfigItem.new(
            key: :project_id,
            env_name: "POEDITOR_PROJECT_ID",
            description: "POEditor projectID (https://poeditor.com/account/api)",
            type: String,
            optional: false,
          ),
          FastlaneCore::ConfigItem.new(
            key: :languages,
            env_name: "POEDITOR_LANGUAGES",
            description: "One or more languages from POEditor (i.e. \"sr-cyrl, de, en\"])",
            type: Array,
            optional: false,
          ),
          FastlaneCore::ConfigItem.new(
            key: :filters,
            env_name: "POEDITOR_FILTERS",
            description: "One or more translation filters from POEditor (i.e. \"translated, fuzzy...\" see https://poeditor.com/docs/api#projects_export)",
            type: Array,
            default_value: "",
            optional: true,
          ),
          FastlaneCore::ConfigItem.new(
            key: :type,
            env_name: "POEDITOR_TYPE",
            description: "The translation file type (i.e. 'yml' see https://poeditor.com/docs/api)",
            type: String,
            default_value: "yml",
            optional: true,
          ),
          FastlaneCore::ConfigItem.new(
            key: :output_dir,
            env_name: "TRANSLATIONS_OUTPUT_DIR",
            description: "The dir whe the translations should be downloaded to",
            type: String,
            default_value: "./",
            optional: true,
          ),
          FastlaneCore::ConfigItem.new(
            key: :output_template,
            env_name: "TRANSLATION_OUTPUT_FILE_PATTERN",
            description: "The translation file pattern (\"translations_%s.i18n.yaml\")",
            type: String,
            default_value: "translations_%s.i18n.yaml",
            optional: true,
          ),
        ]
      end

      def self.authors
        ["@joecks"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
