class UserNotifier < ActionMailer::Base
  include Devise::Mailers::Helpers

  default from: "no-reply@unep-wcmc.org"

  def reset_password_instructions(record, type)
    devise_mail(record, :reset_password_instructions)
  end
end
