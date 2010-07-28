require File.expand_path('../test_helper', __FILE__)

module FriendlyId
  module Test
    module DataMapperAdapter

      # Tests for DataMapper models using FriendlyId with slugs.
      class BasicSluggedTest < ::Test::Unit::TestCase
        include FriendlyId::Test::Generic
        include FriendlyId::Test::Slugged
        include FriendlyId::Test::DataMapperAdapter::Core
        include FriendlyId::Test::DataMapperAdapter::Slugged
      end
    end
  end
end
