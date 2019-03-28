class Officing::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate_user!
  before_action :verify_officer

  skip_authorization_check

  private

    def verify_officer
      raise CanCan::AccessDenied unless current_user.try(:poll_officer?)
    end

    def load_officer_assignment
      @officer_assignments ||= current_user.poll_officer.
                               officer_assignments.
                               voting_days.
                               where(date: Time.current.to_date)
    end

    def verify_officer_assignment
      if @officer_assignments.blank?
        redirect_to officing_root_path, notice: t("officing.residence.flash.not_allowed")
      end
    end

    def verify_booth
      if session[:booth_id].blank?
        redirect_to new_officing_booth_path
      end
    end

end
