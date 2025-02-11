# frozen_string_literal: true

# == Schema Information
#
# Table name: channels
#
#  id           :integer          not null, primary key
#  subject      :string
#  msg_template :jsonb
#  channel_type :integer          default(0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#


# Publish-Subscription Model
class Channel < ApplicationRecord
  has_many :subscriptions
  SYSTEM_UPGRADE = 'System Upgrade'
  SYSTEM_NOTIFICATION = 'System Notification'
  SYSTEM_MAINTENANCE = 'System Maintenance'
  SHARED_COLLECTION_WITH_ME = 'Shared Collection With Me'
  SYNCHRONIZED_COLLECTION_WITH_ME = 'Synchronized Collection With Me'
  INBOX_ARRIVALS_TO_ME = 'Inbox Arrivals To Me'
  REPORT_GENERATOR_NOTIFICATION = 'Report Generator Notification'
  SEND_INDIVIDUAL_USERS = 'Send Individual Users'
  SEND_IMPORT_NOTIFICATION = 'Import Notification'
  COMPUTED_PROPS_NOTIFICATION = 'Computed Prop Notification'
  GATE_TRANSFER_NOTIFICATION = 'Gate Transfer Completed'
  CHEMSCANNER_NOTIFICATION = 'ChemScanner Notification'
  COLLECTION_TAKE_OWNERSHIP = 'Collection Take Ownership'
  EDITOR_CALLBACK = 'EditorCallback'
  COLLECTION_ZIP = 'Collection Import and Export'
  COLLECTION_ZIP_FAIL = 'Collection Import and Export Failure'
  CHEM_SPECTRA_NOTIFICATION = 'Chem Spectra Notification'
  ASSIGN_INBOX_TO_SAMPLE = 'Assign Inbox Attachment to Sample'
  # REPOSITORY ONLY
  PUBLICATION_REVIEW = 'Publication Review'
  PUBLICATION_PUBLISHED = 'Publication Published'

  class << self
    def build_message(**args)
      channel_id = args[:channel_id] # args.delete(:channel_id)
      channel_subject = args[:channel_subject] # args.delete(:channel_subject)
      channel = channel_id ? find_by(id: channel_id) : find_by(subject: channel_subject)
      return unless channel
      data_args = args.delete(:data_args)
      message = channel.msg_template
      if message.present?
        message['channel_id'] = channel.id
        message['data'] = format(message['data'], data_args)
        message = message.merge(args)
      end
      message
    end
  end
end
