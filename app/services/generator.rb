# frozen_string_literal: true

class Generator

  def self.pid(object)
    length = [3,4,5]
    begin
      pid = SecureRandom.alphanumeric(length.sample).downcase
    end while object.class.exists?(pid: pid)
    pid
  end

  def self.code(length)
      SecureRandom.alphanumeric(length).downcase
    end

  def self.confirmation_token(object)
    begin
      confirmation_token = SecureRandom.alphanumeric(12).downcase + '.' + Time.now.utc.to_i.to_s
    end while object.class.exists?(confirmation_token: confirmation_token)
    confirmation_token
  end

  def self.password_reset_token(object)
    begin
      password_reset_token = SecureRandom.alphanumeric(6).downcase + '.' + Time.now.utc.to_i.to_s
    end while object.class.exists?(password_reset_token: password_reset_token)
    password_reset_token
  end

end