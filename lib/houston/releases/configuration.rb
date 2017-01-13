require "houston/releases/null_tag"
require "houston/releases/tag"

module Houston::Releases
  class Configuration

    def change_tags(*args)
      if args.any?
        @tag_map = {}
        args.flatten.each_with_index do |hash, position|
          Houston::Releases::Tag.new(hash.pick(:name, :color).merge(slug: hash[:as], position: position)).tap do |tag|
            @tag_map[tag.slug] = tag
            hash.fetch(:aliases, []).each do |slug|
              @tag_map[slug] = tag
            end
          end
        end
      end
      (@tag_map ||= {}).values.uniq
    end

    def fetch_tag(slug)
      tag_map.fetch(slug, Houston::Releases::NullTag.instance)
    end

    attr_reader :tag_map

  end
end
