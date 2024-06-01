class EventJob
  include Sidekiq::Job

  def perform(event_id)
    event = Event.find(event_id)

    Rails.logger.info([event.id, event.created_at].join(' | '))
  end
end
