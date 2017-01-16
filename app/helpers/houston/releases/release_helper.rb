module Houston
  module Releases
    module ReleaseHelper
      include Houston::Commits::CommitHelper

      def link_to_release_commit_range(release)
        return "" if release.commit0.blank? && release.commit1.blank?
        link_to_commit_range(release.project, release.commit0, release.commit1)
      end

      def releases_path(project, *args)
        options = args.extract_options!
        environment_name = args.first
        if environment_name
          "/projects/#{project.to_param}/environments/#{environment_name}/releases"
        else
          super(project, options)
        end
      end

      def new_release_url(release, options={})
        super(release.project.to_param, release.environment_name, options.merge(deploy_id: release.deploy_id))
      end

      def format_release_date(date)
        "<span class=\"weekday\">#{date.strftime("%A")}</span> #{date.strftime("%b %e, %Y")}".html_safe
      end

      def format_release_subject(release)
        release.date.strftime("%b %e, %Y • ") + release.released_at.strftime("%-I:%M%p").downcase
      end

      def format_release_description(release)
        ordered_by_tag(release.release_changes)
          .map { |change| "#{change.tag.name.upcase}\t#{change.description}" }
          .join("\r\n")
          .html_safe
      end

      def ordered_by_tag(changes)
        changes.sort_by { |change| change.tag ? change.tag.position : 99 }
      end

      def format_release_age(release)
        format_time_ago release && release.created_at
      end

      def replace_quotes(string)
        h(string).gsub(/&quot;(.+?)&quot;/, '<code>\1</code>').html_safe
      end

      def format_change(change)
        mdown change.description
      end

      def format_change_tag(tag)
        "<div class=\"change-tag\" style=\"background-color: ##{tag.color};\">#{tag.name}</div>".html_safe
      end

      def format_commit(commit)
        message = commit.summary
        message = format_with_tickets_linked(commit.project, message)
        message = mdown(message)
        message
      end

      def format_with_tickets_linked(project, message)
        message = h(message)

        if project.respond_to?(:ticket_tracker_ticket_url)
          message.gsub! Commit::TICKET_PATTERN do |match|
            ticket_number = Commit::TICKET_PATTERN.match(match)[1]
            link_to match, project.ticket_tracker_ticket_url(ticket_number), "target" => "_blank", "rel" => "ticket", "data-number" => ticket_number
          end
        end

        message.gsub! Commit::EXTRA_ATTRIBUTE_PATTERN do |match|
          key, value = match.scan(Commit::EXTRA_ATTRIBUTE_PATTERN).first
          format_extra_attribute(key, value)
        end

        message.html_safe
      end

      def format_extra_attribute(key, value)
        "<span class=\"commit-extra-attribute\"><span class=\"commit-extra-attribute-key\">#{key}</span><span class=\"commit-extra-attribute-value\">#{value}</span></span>"
      end

    end
  end
end
