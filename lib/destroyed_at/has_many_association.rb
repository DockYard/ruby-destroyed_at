module DestroyedAt
  module HasManyAssociation
    def delete_records(records, method)
      if method == :destroy
        records.each do |r|
          if r.respond_to?(:destroyed_at) && owner.respond_to?(:destroyed_at)
            r.destroy(owner.destroyed_at)
          else
            r.destroy
          end
        end
        iucc = ActiveRecord::VERSION::MAJOR >= 5 ? reflection.inverse_updates_counter_cache? : inverse_updates_counter_cache?
        update_counter(-records.length) unless iucc
      else
        super
      end
    end
  end
end

ActiveRecord::Associations::HasManyAssociation.send(:prepend, DestroyedAt::HasManyAssociation)
