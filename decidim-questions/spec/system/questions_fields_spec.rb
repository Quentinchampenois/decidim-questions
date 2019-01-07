# frozen_string_literal: true

require "spec_helper"

describe "Questions", type: :system do
  include_context "with a component"
  let(:manifest_name) { "questions" }

  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:scope) { create :scope, organization: organization }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:scoped_participatory_process) { create(:participatory_process, :with_steps, organization: organization, scope: scope) }

  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  let(:question_title) { "More sidewalks and less roads" }
  let(:question_body) { "Cities need more people, not more cars" }

  before do
    stub_geocoding(address, [latitude, longitude])
  end

  matcher :have_author do |name|
    match { |node| node.has_selector?(".author-data", text: name) }
    match_when_negated { |node| node.has_no_selector?(".author-data", text: name) }
  end

  context "when creating a new question" do
    let(:scope_picker) { select_data_picker(:question_scope_id) }

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      context "with creation enabled" do
        let!(:component) do
          create(:question_component,
                 :with_creation_enabled,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end

        let(:question_draft) { create(:question, :draft, component: component) }

        context "when process is not related to any scope" do
          it "can be related to a scope" do
            visit complete_question_path(component, question_draft)

            within "form.edit_question" do
              expect(page).to have_content(/Scope/i)
            end
          end
        end

        context "when process is related to a leaf scope" do
          let(:participatory_process) { scoped_participatory_process }

          it "cannot be related to a scope" do
            visit complete_question_path(component, question_draft)

            within "form.edit_question" do
              expect(page).to have_no_content("Scope")
            end
          end
        end

        it "creates a new question", :slow do
          visit complete_question_path(component, question_draft)

          within ".edit_question" do
            fill_in :question_title, with: "More sidewalks and less roads"
            fill_in :question_body, with: "Cities need more people, not more cars"
            select translated(category.name), from: :question_category_id
            scope_pick scope_picker, scope

            find("*[type=submit]").click
          end

          click_button "Publish"

          expect(page).to have_content("successfully")
          expect(page).to have_content("More sidewalks and less roads")
          expect(page).to have_content("Cities need more people, not more cars")
          expect(page).to have_content(translated(category.name))
          expect(page).to have_content(translated(scope.name))
          expect(page).to have_author(user.name)
        end

        context "when geocoding is enabled", :serves_map do
          let!(:component) do
            create(:question_component,
                   :with_creation_enabled,
                   :with_geocoding_enabled,
                   manifest: manifest,
                   participatory_space: participatory_process)
          end

          let(:question_draft) { create(:question, :draft, users: [user], component: component, title: "More sidewalks and less roads", body: "He will not solve everything") }

          it "creates a new question", :slow do
            visit complete_question_path(component, question_draft)

            within ".edit_question" do
              check :question_has_address
              fill_in :question_title, with: "More sidewalks and less roads"
              fill_in :question_body, with: "Cities need more people, not more cars"
              fill_in :question_address, with: address
              select translated(category.name), from: :question_category_id
              scope_pick scope_picker, scope

              find("*[type=submit]").click
            end

            click_button "Publish"

            expect(page).to have_content("successfully")
            expect(page).to have_content("More sidewalks and less roads")
            expect(page).to have_content("Cities need more people, not more cars")
            expect(page).to have_content(address)
            expect(page).to have_content(translated(category.name))
            expect(page).to have_content(translated(scope.name))
            expect(page).to have_author(user.name)
          end
        end

        context "when component has extra hashtags defined" do
          let(:component) do
            create(:question_component,
                   :with_extra_hashtags,
                   suggested_hashtags: component_suggested_hashtags,
                   automatic_hashtags: component_automatic_hashtags,
                   manifest: manifest,
                   participatory_space: participatory_process)
          end

          let(:question_draft) { create(:question, :draft, users: [user], component: component, title: "More sidewalks and less roads", body: "He will not solve everything") }
          let(:component_automatic_hashtags) { "AutoHashtag1 AutoHashtag2" }
          let(:component_suggested_hashtags) { "SuggestedHashtag1 SuggestedHashtag2" }

          it "offers and save extra hashtags", :slow do
            visit complete_question_path(component, question_draft)

            within ".edit_question" do
              check :question_suggested_hashtags_suggestedhashtag1

              find("*[type=submit]").click
            end

            click_button "Publish"

            expect(page).to have_content("successfully")
            expect(page).to have_content("#AutoHashtag1")
            expect(page).to have_content("#AutoHashtag2")
            expect(page).to have_content("#SuggestedHashtag1")
            expect(page).not_to have_content("#SuggestedHashtag2")
          end
        end

        context "when the user has verified organizations" do
          let(:user_group) { create(:user_group, :verified, organization: organization) }
          let(:user_group_question_draft) { create(:question, :draft, users: [user], component: component, title: "More sidewalks and less roads", body: "Cities need more people, not more cars") }

          before do
            create(:user_group_membership, user: user, user_group: user_group)
          end

          it "creates a new question as a user group", :slow do
            visit complete_question_path(component, user_group_question_draft)

            within ".edit_question" do
              fill_in :question_title, with: "More sidewalks and less roads"
              fill_in :question_body, with: "Cities need more people, not more cars"
              select translated(category.name), from: :question_category_id
              scope_pick scope_picker, scope
              select user_group.name, from: :question_user_group_id

              find("*[type=submit]").click
            end

            click_button "Publish"

            expect(page).to have_content("successfully")
            expect(page).to have_content("More sidewalks and less roads")
            expect(page).to have_content("Cities need more people, not more cars")
            expect(page).to have_content(translated(category.name))
            expect(page).to have_content(translated(scope.name))
            expect(page).to have_author(user_group.name)
          end

          context "when geocoding is enabled", :serves_map do
            let!(:component) do
              create(:question_component,
                     :with_creation_enabled,
                     :with_geocoding_enabled,
                     manifest: manifest,
                     participatory_space: participatory_process)
            end

            let(:question_draft) { create(:question, :draft, users: [user], component: component, title: "More sidewalks and less roads", body: "He will not solve everything") }

            it "creates a new question as a user group", :slow do
              visit complete_question_path(component, question_draft)

              within ".edit_question" do
                fill_in :question_title, with: "More sidewalks and less roads"
                fill_in :question_body, with: "Cities need more people, not more cars"
                check :question_has_address
                fill_in :question_address, with: address
                select translated(category.name), from: :question_category_id
                scope_pick scope_picker, scope
                select user_group.name, from: :question_user_group_id

                find("*[type=submit]").click
              end

              click_button "Publish"

              expect(page).to have_content("successfully")
              expect(page).to have_content("More sidewalks and less roads")
              expect(page).to have_content("Cities need more people, not more cars")
              expect(page).to have_content(address)
              expect(page).to have_content(translated(category.name))
              expect(page).to have_content(translated(scope.name))
              expect(page).to have_author(user_group.name)
            end
          end
        end

        context "when the user isn't authorized" do
          before do
            permissions = {
              create: {
                authorization_handler_name: "dummy_authorization_handler"
              }
            }

            component.update!(permissions: permissions)
          end

          it "shows a modal dialog" do
            visit_component
            click_link "New question"
            expect(page).to have_content("Authorization required")
          end
        end

        context "when attachments are allowed", processing_uploads_for: Decidim::AttachmentUploader do
          let!(:component) do
            create(:question_component,
                   :with_creation_enabled,
                   :with_attachments_allowed,
                   manifest: manifest,
                   participatory_space: participatory_process)
          end

          let(:question_draft) { create(:question, :draft, users: [user], component: component, title: "Question with attachments", body: "This is my question and I want to upload attachments.") }

          it "creates a new question with attachments" do
            visit complete_question_path(component, question_draft)

            within ".edit_question" do
              fill_in :question_title, with: "Question with attachments"
              fill_in :question_body, with: "This is my question and I want to upload attachments."
              fill_in :question_attachment_title, with: "My attachment"
              attach_file :question_attachment_file, Decidim::Dev.asset("city.jpeg")
              find("*[type=submit]").click
            end

            click_button "Publish"

            expect(page).to have_content("successfully")

            within ".section.images" do
              expect(page).to have_selector("img[src*=\"city.jpeg\"]", count: 1)
            end
          end
        end
      end

      context "when creation is not enabled" do
        it "does not show the creation button" do
          visit_component
          expect(page).to have_no_link("New question")
        end
      end

      context "when the question limit is 1" do
        let!(:component) do
          create(:question_component,
                 :with_creation_enabled,
                 :with_question_limit,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end

        let!(:question_first) { create(:question, users: [user], component: component, title: "Creating my first and only question", body: "This is my only question's body and I'm using it unwisely.") }

        before do
          visit_component
          click_link "New question"
        end

        it "allows the creation of a single new question" do
          within ".new_question" do
            fill_in :question_title, with: "Creating my second question"
            fill_in :question_body, with: "This is my second question's body and I'm using it unwisely."

            find("*[type=submit]").click
          end

          expect(page).to have_no_content("successfully")
          expect(page).to have_css(".callout.alert", text: "limit")
        end
      end
    end
  end
end

def complete_question_path(component, question)
  Decidim::EngineRouter.main_proxy(component).question_path(question) + "/complete"
end
