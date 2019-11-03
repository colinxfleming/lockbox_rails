class CapybaraSessionsHelper
  class << self
    def in_session(id, &block)
      @sessions ||= { default: Capybara.session_name }
      Capybara.session_name = id
      yield
      Capybara.session_name = @sessions[:default]
    end
  end
end

def in_session(id, &block)
  CapybaraSessionsHelper.in_session(id, &block)
end
