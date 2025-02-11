# frozen_string_literal: true

require 'rails_helper'

describe 'Copy reaction' do
  let!(:user1) { create(:user, first_name: 'User1', last_name: 'Complat', name_abbreviation: 'US1', account_active: true, confirmed_at: Time.now) }
  let!(:user2) { create(:user, first_name: 'User2', last_name: 'Complat', name_abbreviation: 'US2', account_active: true, confirmed_at: Time.now) }

  let!(:m1) { create(:molecule, molecular_weight: 171.03448) }
  let!(:m2) { create(:molecule, molecular_weight: 133.15058) }

  let(:material1) { create(:sample, name: 'Material1', target_amount_value: 7.15, molecule: m1) }
  let(:product1) { create(:sample, name: 'Product1', real_amount_value: 4.671, molecule: m2) }
  let(:reaction1) { create(:reaction, status: 'Successful', short_label: 'Reaction1') }

  let(:material2) { create(:sample, name: 'Material2', target_amount_value: 7.15, molecule: m1) }
  let(:product2) { create(:sample, name: 'Product2', real_amount_value: 4.671, molecule: m2) }
  let(:reaction2) { create(:reaction, status: 'Successful', short_label: 'Reaction2') }

  let!(:col1) { create(:collection, user_id: user1.id, label: 'Col1') }
  let!(:col2) { create(:collection, user_id: user1.id, label: 'Col2') }

  let!(:root_share) { create(:collection, user: user1, shared_by_id: user2.id, is_shared: true, is_locked: true) }
  let!(:col1_shared) { create(:collection, user: user1, label: 'Col1-shared', permission_level: 10,
    sample_detail_level: 10, reaction_detail_level: 10, shared_by_id: user2.id, is_shared: true, ancestry: root_share.id.to_s) }
  let!(:col2_shared) { create(:collection, user: user1, label: 'Col2-shared', permission_level: 10,
    sample_detail_level: 0, reaction_detail_level: 0, shared_by_id: user2.id, is_shared: true, ancestry: root_share.id.to_s) }

  def copy_reaction(source_collection, target_collection)
    find_by_id("tree-id-#{source_collection}").click
    find('i.icon-reaction').click
    find('div.preview-table', text: 'Reaction').click
    click_button('copy-element-btn')
    fill_in('modal-collection-id-select', with: target_collection).send_keys(:enter)
    click_button('submit-copy-element-btn') # ELN switches over to `target_collection` at this point
    expect(page).to have_css("div#tree-id-#{target_collection}.title.selected") # wait until ELN switched to `target_collection`
    expect(page).to have_content('According to General Procedure', wait: 5) # assert that ELN opened tab for copied reaction
    fill_in('reaction_name', with: 'copied-reaction')
    click_button('submit-reaction-btn')
    expect(page).to have_css('div.preview-table', text: 'copied-reaction', wait: 5) # assert that copied reaction appears in reaction table
  end

  context 'from own collection' do
    before do
      sign_in(user1)

      fp = Rails.public_path.join('images', 'molecules', 'molecule.svg')
      svg_path = Rails.root.join('spec', 'fixtures', 'images', 'molecule.svg')
      `ln -s #{svg_path} #{fp} ` unless File.exist?(fp)

      CollectionsSample.find_or_create_by!(sample: material1, collection: col1)
      CollectionsSample.find_or_create_by!(sample: product1, collection: col1)
      CollectionsReaction.find_or_create_by!(reaction: reaction1, collection: col1)
      ReactionsStartingMaterialSample.create!(reaction: reaction1, sample: material1, reference: true, equivalent: 1)
      ReactionsProductSample.create!(reaction: reaction1, sample: product1, equivalent: 1)

      CollectionsSample.find_or_create_by!(sample: material2, collection: col2)
      CollectionsSample.find_or_create_by!(sample: product2, collection: col2)
      CollectionsReaction.find_or_create_by!(reaction: reaction2, collection: col2)
      ReactionsStartingMaterialSample.create!(reaction: reaction2, sample: material2, reference: true, equivalent: 1)
      ReactionsProductSample.create!(reaction: reaction2, sample: product2, equivalent: 1)
    end

    it 'to different own collection', js: true do
      copy_reaction('Col1', 'Col2')
    end

    it 'to same own collection', js: true do
      copy_reaction('Col1', 'Col1')
    end
  end

  context 'from shared-with-me collection' do
    before do
      sign_in(user1)
      fp = Rails.public_path.join('images', 'molecules', 'molecule.svg')
      svg_path = Rails.root.join('spec', 'fixtures', 'images', 'molecule.svg')
      `ln -s #{svg_path} #{fp} ` unless File.exist?(fp)

      CollectionsSample.find_or_create_by!(sample: material1, collection: col1_shared)
      CollectionsSample.find_or_create_by!(sample: product1, collection: col1_shared)
      CollectionsReaction.find_or_create_by!(reaction: reaction1, collection: col1_shared)
      ReactionsStartingMaterialSample.create!(reaction: reaction1, sample: material1, reference: true, equivalent: 1)
      ReactionsProductSample.create!(reaction: reaction1, sample: product1, equivalent: 1)

      CollectionsSample.find_or_create_by!(sample: material2, collection: col2_shared)
      CollectionsSample.find_or_create_by!(sample: product2, collection: col2_shared)
      CollectionsReaction.find_or_create_by!(reaction: reaction2, collection: col2_shared)
      ReactionsStartingMaterialSample.create!(reaction: reaction2, sample: material2, reference: true, equivalent: 1)
      ReactionsProductSample.create!(reaction: reaction2, sample: product2, equivalent: 1)
    end

    it 'with copy permission to own collection', js: true do
      find_by_id('shared-home-link').click
      find('span.glyphicon-plus').click
      copy_reaction('Col1-shared', 'Col1')
    end

    it 'without copy permission to own collection', js: true do
      find_by_id('shared-home-link').click
      find('span.glyphicon-plus').click
      find_by_id('tree-id-Col2-shared').click
      find('i.icon-reaction').click
      find('div.preview-table', text: '*** ***', exact_text: true).click
      expect(page).not_to have_button('copy-element-btn')
    end
  end
end
