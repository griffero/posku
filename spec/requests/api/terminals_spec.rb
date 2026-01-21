# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::Terminals" do
  describe "GET /api/terminals" do
    before do
      create_list(:terminal, 3, active: true)
      create(:terminal, active: false)
    end

    it "returns only active terminals" do
      get "/api/terminals"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["terminals"].count).to eq(3)
    end

    it "includes required terminal attributes" do
      get "/api/terminals"

      json = JSON.parse(response.body)
      terminal = json["terminals"].first

      expect(terminal).to include(
        "id", "name", "city", "code", "display_name", "latitude", "longitude"
      )
    end
  end

  describe "GET /api/terminals/:id" do
    let(:terminal) { create(:terminal) }

    it "returns the terminal" do
      get "/api/terminals/#{terminal.id}"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["terminal"]["id"]).to eq(terminal.id)
    end

    it "returns 404 for non-existent terminal" do
      get "/api/terminals/99999"

      expect(response).to have_http_status(:not_found)
    end
  end
end
