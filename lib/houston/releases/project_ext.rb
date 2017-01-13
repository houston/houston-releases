module Houston
  module Releases
    module ProjectExt
      extend ActiveSupport::Concern

      included do
        has_many :releases, dependent: :destroy, class_name: "Houston::Releases::Release"
      end


      def environments_with_release_notes
        environments.select(&method(:show_release_notes_for?))
      end

      def show_release_notes_for?(environment_name)
        props["releases.ignore.#{environment_name.downcase}"] != "1"
      end

    end
  end
end
