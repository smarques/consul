class Budget::Investment::Exporter
  require 'csv'

  def initialize(investments)
    @investments = investments
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      @investments.each { |investment| csv << csv_values(investment) }
    end
  end

  private

  def headers
    [
      I18n.t("admin.budget_investments.index.table_id"),
      I18n.t("admin.budget_investments.index.table_title"),
      I18n.t("admin.budget_investments.index.table_supports"),
      I18n.t("admin.budget_investments.index.table_admin"),
      I18n.t("admin.budget_investments.index.table_valuator"),
      I18n.t("admin.budget_investments.index.table_valuation_group"),
      I18n.t("admin.budget_investments.index.table_geozone"),
      I18n.t("admin.budget_investments.index.table_feasibility"),
      I18n.t("admin.budget_investments.index.table_valuation_finished"),
      I18n.t("admin.budget_investments.index.table_selection")
    ]
  end

  def csv_values(investment)
    [
      investment.id.to_s,
      investment.title,
      investment.total_votes.to_s,
      admin(investment),
      investment.assigned_valuators || '-',
      investment.assigned_valuation_groups || '-',
      investment.heading.name,
      price(investment),
      investment.valuation_finished? ? I18n.t('shared.yes') : I18n.t('shared.no'),
      investment.selected? ? I18n.t('shared.yes') : I18n.t('shared.no')
    ]
  end

  def admin(investment)
    if investment.administrator.present?
      investment.administrator.name
    else
      I18n.t("admin.budget_investments.index.no_admin_assigned")
    end
  end

  def price(investment)
    price_string = "admin.budget_investments.index.feasibility.#{investment.feasibility}"
    I18n.t(price_string, price: investment.formatted_price)
  end
end
