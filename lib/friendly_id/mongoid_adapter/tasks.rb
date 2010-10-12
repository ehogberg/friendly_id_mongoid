require 'active_support/core_ext'

module FriendlyId
  class TaskRunner

    extend Forwardable

    attr_accessor :days
    attr_accessor :klass
    attr_accessor :task_options

    def_delegators :klass, :find, :friendly_id_config

    OLD_SLUG_DAYS = 45

    def initialize(&block)
      self.klass = ENV["MODEL"]
      self.days  = ENV["DAYS"]
    end

    def days=(days)
      @days ||= days.blank? ? OLD_SLUG_DAYS : days.to_i
    end

    def klass=(klass)
      @klass ||= klass.to_s.classify.constantize unless klass.blank?
    end

    def make_slugs
      validate_uses_slugs
      options = {:limit => 100, :slugs => nil, :order => [:id.asc]}.merge(task_options || {})
      while records = klass.all(options) do
        break if records.size == 0
        records.each do |record|
          record.send(:build_slug)  # FIXME: DataMapper Hack: this hook is not getting called
          record.save
          yield(record) if block_given?
        end
        options.merge!(:id.gt => records.last.id)
      end
    end

    def delete_slugs
      validate_uses_slugs
      Slug.all(:sluggable_type => klass).destroy!
      if column = friendly_id_config.cache_column
        klass.all.update!(column => nil)
      end
    end

    def delete_old_slugs
      conditions = ["created_at < ?", DateTime.now - days]
      if klass
        conditions[0] << " AND sluggable_type = ?"
        conditions << klass.to_s
      end
      Slug.all(:conditions => conditions).select(&:outdated?).map(&:destroy)
    end

    def validate_uses_slugs
      (raise "You need to pass a MODEL=<model name> argument to rake") if klass.blank?
      unless friendly_id_config.use_slug?
        raise "Class '%s' doesn't use slugs" % klass.to_s
      end
    rescue NoMethodError
      raise "Class '%s' doesn't use FriendlyId" % klass.to_s
    end
  end
end
