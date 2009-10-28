# coding: utf-8

require "time"
require "digest/sha1"

module Wsse
  module UsernameTokenBuilder
    def self.create_created_time(time = Time.now)
      return time.utc.iso8601
    end

    # FIXME: サイズを指定できるように変更
    def self.create_nonce
      return 20.times.map { rand(256) }.pack("C*")
    end

    # FIXME: create_password_digestメソッドを追加

    def self.create_token_params(username, password, nonce = nil, created = nil)
      nonce   ||= self.create_nonce
      created ||= self.create_created_time
      digest = Digest::SHA1.digest(nonce + created + password)
      return {
        "Username"       => username,
        "PasswordDigest" => [digest].pack("m").chomp,
        "Nonce"          => [nonce].pack("m").chomp,
        "Created"        => created,
      }
    end

    def self.format_token(params)
      return format(
        %|UsernameToken Username="%s", PasswordDigest="%s", Nonce="%s", Created="%s"|,
        (params["Username"]       || raise(ArgumentError)),
        (params["PasswordDigest"] || raise(ArgumentError)),
        (params["Nonce"]          || raise(ArgumentError)),
        (params["Created"]        || raise(ArgumentError)))
    end

    def self.create_token(username, password, nonce = nil, created = nil)
      params = self.create_token_params(username, password, nonce, created)
      return self.format_token(params)
    end
  end
end
