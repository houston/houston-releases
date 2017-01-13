module Houston
  module Releases
    class Tag

      def initialize(options={})
        @name = options[:name]
        @slug = options[:slug]
        @color = options[:color]
        @position = options[:position]
      end

      attr_reader :name
      attr_reader :slug
      attr_reader :color
      attr_reader :position

      def to_partial_path
        "tags/tag"
      end

    end
  end
end
