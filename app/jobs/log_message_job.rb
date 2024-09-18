class LogMessageJob < ApplicationJob
  queue_as :default

  def perform
    puts "LogMessageJob COMMENCE"
  end

end
