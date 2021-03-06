# frozen_string_literal: true

module Decidim
  module Questions
    module Admin
      # A form object to be used when admin users want to import a collection of questions
      # from a participatory text.
      class ImportParticipatoryTextForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :document

        validates :title, translatable_presence: true

        def default_locale
          current_participatory_space.organization.default_locale
        end

        def document_text
          @document_text ||= document&.read
        end

        def document_type
          document.content_type
        end
      end
    end
  end
end
