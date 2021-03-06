# frozen-string_literal: true

module Decidim
  module Questions
    module Admin
      class ValidateQuestionEvent < Decidim::Questions::Events::WorkflowEvent
        def resource_text
          resource.body
        end

        def resource_url
          EngineRouter.admin_proxy(component).edit_question_question_answer_url(question_id: resource.id, id: resource.id)
        end
      end
    end
  end
end
