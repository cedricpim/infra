class TestJob
  include Sidekiq::Job

  def perform(*args)
    puts "Test"
  end
end
