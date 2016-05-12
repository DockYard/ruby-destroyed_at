class DestroyedAt::RecordNotRestored < ActiveRecord::ActiveRecordError
  attr_reader :record
  def initialize(record)
    @record = record
    super()
  end
end