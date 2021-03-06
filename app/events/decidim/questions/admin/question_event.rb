# frozen_string_literal: true

module Decidim
  module Questions
    module Admin
      class QuestionEvent < Decidim::UpstreamEvent
        include Decidim::Questions::Events::QuestionEvent

        private

        def default_i18n_options
          {
            user_name: user_name,
            user_pseudo: user_nickname,
            resource_path: resource_path,
            resource_title: resource_title,
            resource_url: resource_url,
            question_title: resource_title,
            question_body: question_body,
            question_answer: question_answer,
            question_reference: question_reference,
            question_short_ref: question_short_ref,
            question_path: resource_path,
            question_url: resource_url,
            question_admin_edit_url: question_admin_edit_url,
            question_admin_answer_url: question_admin_answer_url,
            question_admin_privates_notes_url: question_admin_privates_notes_url,
            participatory_space_title: participatory_space_title,
            participatory_space_url: participatory_space_url,
            participatory_space_slug: participatory_space_url,
            participatory_space_id: participatory_space_url,
            manage_resource_url: manage_resource_url,
            manage_moderation_url: manage_moderation_url,
            scope: i18n_scope
          }
        end
      end
    end
  end
end
