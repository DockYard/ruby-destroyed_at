require "destroyed_at/version"

module DestroyedAt
  def self.included(klass)
    klass.instance_eval do
      default_scope { where(destroyed_at: nil) }
      after_initialize :_set_destruction_state
      define_model_callbacks :restore
    end
  end

  # Set an object's destroyed_at time.
  def destroy
    run_callbacks(:destroy) do
      destroy_associations
      self.update_attribute(:destroyed_at, _get_destroy_time)
      @destroyed = true
    end
  end

  # Set an object's destroyed_at time to nil.
  def restore
    state = nil
    run_callbacks(:restore) do
      destroyed_time = self.destroyed_at
      if state = self.update_attribute(:destroyed_at, nil)
        @destroyed = false
        _restore_associations destroyed_time
      end
    end
    state
  end

  private

  def _get_destroy_time
    @@destroy_time ||= current_time_from_proper_timezone
  end

  def _set_destruction_state
    @@destroy_time = nil
    @destroyed = destroyed_at.present? if has_attribute?(:destroyed_at)
    # Don't stop the other callbacks from running
    true
  end

  def _restore_associations(destroyed_time)
    reflections.select { |key, value| value.options[:dependent] == :destroy }.keys.each do |key|
      assoc = association(key)
      if assoc.options[:through] && assoc.options[:dependent] == :destroy
        assoc = association(assoc.options[:through])
      end
      assoc.association_scope.each { |r| r.restore if r.respond_to?(:restore) && (r.destroyed_at.to_i == destroyed_time.to_i) }
    end
  end
end
