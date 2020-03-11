require "rails_helper"

describe "shared errors" do
  class DummyModel
    include ActiveModel::Model
    attr_accessor :title, :description, :days

    validates :title, presence: true
    validates :description, presence: true, length: { in: 10..100 }
    validates :days, numericality: { greater_than: 10 }
  end

  class DummyBaseModel < DummyModel
    attr_accessor :base
    validates :base, presence: true
  end

  it "counts the number of fields with errors" do
    resource = DummyModel.new(title: "Present", description: "", days: 3)
    resource.valid?

    render "shared/errors", resource: resource

    expect(rendered).to have_content "2 errors"
  end

  it "doesn't include `base` errors" do
    resource = DummyBaseModel.new(title: "Present", base: "", description: "", days: 3)
    resource.valid?

    render "shared/errors", resource: resource

    expect(rendered).to have_content "2 errors"
  end
end
