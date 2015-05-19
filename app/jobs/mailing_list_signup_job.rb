class MailingListSignupJob < ActiveJob::Base
  def perform(visitor)
    logger.info "Signing up #{visitor.email}"
    visitor.subscribe
  end
end