module ApplicationCable
    class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verfied_user
    end

    protected

    def find_verfied_user
      # We can just access Warden directly to find out if the user is logged in or not
      # Using Warden directly will give us access to that as it's what Devise uses internally for authentication
      if current_user = env['warden'].user
        current_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
