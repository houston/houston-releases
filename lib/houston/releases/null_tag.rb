module Houston
  module Releases
    class NullTag

      def self.instance
        @instance ||= self.new
      end

      def nil?
        true
      end

      def slug
        nil
      end

      def color
        "CCCCCC"
      end

      def name
        "No tag"
      end

      def position
        999
      end

    end
  end
end
