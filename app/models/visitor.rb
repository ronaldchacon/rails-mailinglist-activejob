class Visitor < ActiveRecord::Base
  EMAIL_FORMAT = /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i
  validates :email, presence: true, format: {with: EMAIL_FORMAT}

  after_create :sign_up_for_mailing_list
  after_initialize :defaults

  def defaults
    self.affinity = 'NONE' unless self.affinity == 'KITTENS'
  end

  def sign_up_for_mailing_list
    MailingListSignupJob.perform_later(self)
  end

  def subscribe
    mailchimp = Gibbon::API.new(ENV['MAILCHIMP_API_KEY'])
    result = mailchimp.lists.subscribe({
      id: ENV['MAILCHIMP_LIST_ID'],
      email: {email: self.email},
      merge_vars: {referrer: self.referrer.truncate(252, omission: '...'),
                   groupings: [{name: 'AFFINITY',
                                groups: [self.affinity.upcase]
                              }]
                  },
      double_optin: false,
      update_existing: true,
      send_welcome: true
    })
    Rails.logger.info("Subscribed #{self.email} to MailChimp") if result
  end
end
