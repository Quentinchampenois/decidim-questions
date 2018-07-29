# frozen_string_literal: true

module Decidim
  module Questions
    module Admin
      # A command with all the business logic when an admin creates a private note question.
      class CreateQuestionNote < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # question - the question to relate.
        def initialize(form, question)
          @form = form
          @question = question
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the note question.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          create_question_note

          broadcast(:ok, question_note)
        end

        private

        attr_reader :form, :question_note, :question

        def create_question_note
          @question_note = Decidim.traceability.create!(
            QuestionNote,
            form.current_user,
            {
              body: form.body,
              question: question,
              author: form.current_user
            },
            resource: {
              title: question.title
            }
          )
        end
      end
    end
  end
end
