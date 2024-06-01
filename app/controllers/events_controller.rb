class EventsController < ApplicationController
  def index
    @events = Event.all
  end

  def create
    event = Event.create!
    EventJob.perform_async(event.id)

    redirect_to root_path
  end
end
