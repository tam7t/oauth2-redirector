require 'sinatra'
require 'pry'
require 'capybara'
require 'capybara/dsl'
require 'selenium-webdriver'

include Capybara::DSL

profile = Selenium::WebDriver::Firefox::Profile.new
profile.add_extension 'noredirect-latest.xpi'
profile['extensions.noredirect.list'] = '^https://.*::5:::^http://.*::5'

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile)
end

Capybara.current_driver = :selenium

def follow_redirect_to(matcher)
  while page.has_xpath? '//div[starts-with(@id, "NoRedirect-NotificationBanner")]'
    redirect = page.find :xpath, '//div[starts-with(@id, "NoRedirect-NotificationBanner")]/a'
    return if redirect.nil?

    if matcher && redirect.text.start_with?(matcher)
      return redirect.text
    else
      redirect.click
    end
  end
end

def login_to_facebook(username, password)
  visit('https://www.facebook.com/?_rdr')
  fill_in('email', with: username)
  fill_in('Password', with: password)
  click_button('Log In')
  follow_redirect_to(nil)
end

def authorize_app
  while page.has_button?('Okay')
    page.click_button('Okay')
  end
end

def connect_uri
  ENV['CONNECT_URI']
end

def redirect_uri
  ENV['REDIRECT_URI']
end

def fb_user
  ENV['FB_USER']
end

def fb_pass
  ENV['FB_PASS']
end

get '/' do
  login_to_facebook(fb_user, fb_pass)
  visit(connect_uri)
  authorize_app
  csrf_link = follow_redirect_to(redirect_uri)
  redirect to(csrf_link)
end
