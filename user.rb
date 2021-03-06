class UserSession < Authlogic::Session::Base
end

class User < ActiveRecord::Base
  acts_as_authentic do |c|
    # Bcrypt is recommended
    #crypto_provider = Authlogic::CryptoProviders::BCrypt
    c.perishable_token_valid_for( 24*60*60 )
    c.validates_length_of_password_field_options =
     {:on => :update, :minimum => 6, :if => :has_no_credentials?}
    c.validates_length_of_password_confirmation_field_options =
     {:on => :update, :minimum => 6, :if => :has_no_credentials?}
  end
  
  def active?
    active
  end
  
  def has_no_credentials?
    crypted_password.blank? #&& self.openid_identifier.blank?
  end
  
  def send_activation_email
    Pony.mail(
      :to => self.email,
      :from => "no-reply@domain.tld",
      :subject => "Activate your account",
      :body =>  "You can activate your account at this link: " +
                "http://domain.tld/activate/#{self.perishable_token}"
    )
  end
  
  def send_password_reset_email
    Pony.mail(
      :to => self.email,
      :from => "no-reply@domain.tld",
      :subject => "Reset your password",
      :body => "We have recieved a request to reset your password. " +
               "If you did not send this request, then please ignore this email.\n\n" +
               "If you did send the request, you may reset your password using the following link: " +
                "http://domain.tld/reset-password/#{self.perishable_token}"
    )
  end
end
