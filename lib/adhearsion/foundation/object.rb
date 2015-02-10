# encoding: utf-8

require 'adhearsion/logging'

class Object
  include Adhearsion::Logging::HasLogger

  undef :pb_logger
  def pb_logger
    logger
  end
end

module Celluloid
  class ActorProxy
    def logger
      if current_actor = Thread.current[:celluloid_actor]
        current_actor.bare_object.send :logger
      else
        Actor.call @mailbox, :logger
      end
    end
    alias pb_logger logger
  end
end
