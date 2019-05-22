# encoding: utf-8

require 'concurrent/map'

module Adhearsion
  ##
  # This manages the list of calls the Adhearsion service receives
  class Calls

    delegate :[], :key, :keys, :values, :size, :each, :delete, to: :@calls

    def initialize
      @calls = Concurrent::Map.new

      restart_supervisor
    end

    def <<(call)
      @supervisor.link call

      @calls[call.id] = call
      self
    end

    def remove_inactive_call(call)
      if call_is_dead?(call)
        call_id = key call
        @calls.delete call_id if call_id

      elsif call.respond_to?(:id)
        @calls.delete call.id
      else
        @calls.delete call
      end
    end

    def with_tag(tag)
      @calls.values.find_all do |call|
        begin
          call.tagged_with? tag
        rescue Call::ExpiredError
          false
        end
      end
    end

    def with_uri(uri)
      @calls.each_value do |call|
        begin
          return call if call.uri == uri
        rescue Call::ExpiredError
        end
      end
      nil
    end

    # @private only for specs
    def restart_supervisor
      @supervisor.terminate if (@supervisor ||= nil)
      @supervisor = Supervisor.new self
    end

    private

    def call_is_dead?(call)
      !call.alive?
    rescue ::NoMethodError
      false
    end

    class Supervisor
      include Celluloid

      trap_exit :call_died

      def initialize(collection)
        @collection = collection
      end

      def call_died(call, reason)
        catching_standard_errors do
          call_id = @collection.key call
          @collection.remove_inactive_call call
          return unless reason
          Adhearsion::Events.trigger :exception, reason
          logger.error "Call #{call_id} terminated abnormally due to #{reason.inspect}. Forcing hangup."
          Adhearsion.client.execute_command Adhearsion::Rayo::Command::Hangup.new, :async => true, :call_id => call_id
        end
      end
    end
  end
end
