class TracksController < ApplicationController
  before_action :set_track, only: [:show, :edit, :update, :destroy]
  protect_from_forgery except: :create

  # POST /tracks
  # POST /tracks.json
  def create
    @track = Track.create(track_params)
    render status: 200, json: @track.to_json
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_track
      @track = Track.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def track_params
      params.require(:track).permit(:timestamp, :username, :hostname, :location, :ssid, :rssi, :noise, :max_rate, :rate, :inet_speed, :inet_ping, :lan_speed, :lan_ping)
    end
end
