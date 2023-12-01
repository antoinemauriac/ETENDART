class SayHelloJob < ApplicationJob
  queue_as :default

  def perform
    puts "Hello"
  end
end
