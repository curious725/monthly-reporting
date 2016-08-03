module Users
  class InvitationsController < Devise::InvitationsController
  private

    def accept_resource
      resource = resource_class.accept_invitation!(update_resource_params)
      resource.receive_initial_available_vacations
      resource
    end
  end
end
