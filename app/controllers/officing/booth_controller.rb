class Officing::BoothController < Officing::BaseController
  before_action :load_officer_assignment
  before_action :verify_officer_assignment

  def new
    load_booths

    if only_one_booth?
      set_booth(@booths.first)
      redirect_to officing_root_path, notice: t("officing.booth.new.success", booth: @booths.first.name)
    end
  end

  def create
    find_booth
    set_booth(@booth)
    redirect_to officing_root_path, notice: t("officing.booth.new.success", booth: @booth.name)
  end

  private

  def booth_params
    params.require(:booth).permit(:id)
  end

  def load_booths
    officer = current_user.poll_officer
    @booths = officer.officer_assignments.by_date(Date.today).map(&:booth)
  end

  def only_one_booth?
    @booths.count == 1
  end

  def find_booth
    @booth = Poll::Booth.find(booth_params[:id])
  end

  def set_booth(booth)
    session[:booth_id] = booth.id
  end

end
