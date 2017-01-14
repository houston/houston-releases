module Houston
  module Releases
    class Release < ActiveRecord::Base
      self.table_name = "releases"

      after_create :load_commits!, :if => :can_read_commits?
      after_create { Houston.observer.fire "release:create", release: self }
      after_save :update_search_vector, :if => :search_vector_should_change?

      belongs_to :project
      belongs_to :user
      belongs_to :deploy
      belongs_to :commit_before, class_name: "Commit"
      belongs_to :commit_after, class_name: "Commit"
      has_and_belongs_to_many :commits, autosave: false # <-- a bug with autosave causes commit_ids to be saved twice

      default_scope { order("created_at DESC") }

      validates_presence_of :user_id
      validates_uniqueness_of :deploy_id, :allow_nil => true
      validates_associated :release_changes



      class << self
        def to_environment(environment_name)
          where(environment_name: environment_name)
        end
        alias :to :to_environment

        def for_projects(*projects)
          ids = projects.flatten.map { |project| project.is_a?(Project) ? project.id : project }
          where(project_id: ids)
        end

        def for_deploy(deploy)
          where(deploy_id: deploy.id)
        end

        def most_recent_commit
          release = where(arel_table[:commit1].not_eq("")).first
          release ? release.commit1 : Houston::NULL_GIT_COMMIT
        end

        def before(time)
          return all if time.nil?
          where(arel_table[:created_at].lt(time))
        end

        def after(time)
          return all if time.nil?
          where(arel_table[:created_at].gt(time))
        end

        def latest
          first
        end

        def earliest
          last
        end

        def with_message
          where arel_table[:message].not_eq("")
        end

        def most_recent
          joins <<-SQL
            INNER JOIN (
              SELECT project_id, environment_name, MAX(created_at) AS created_at
              FROM releases
              GROUP BY project_id, environment_name
            ) AS most_recent_releases
            ON releases.project_id=most_recent_releases.project_id
            AND releases.environment_name=most_recent_releases.environment_name
            AND releases.created_at=most_recent_releases.created_at
          SQL
        end

        def reindex!
          update_all "search_vector = to_tsvector('english', release_changes)"
        end

        def search(query_string)
          config = PgSearch::Configuration.new({against: "plain_text"}, self)
          normalizer = PgSearch::Normalizer.new(config)
          options = { dictionary: "english", tsvector_column: "search_vector" }
          query = PgSearch::Features::TSearch.new(query_string, options, config.columns, self, normalizer)

          excerpt = ts_headline(:release_changes, query,
            start_sel: "<em>",
            stop_sel: "</em>",

            # Hack: show the entire value of `release_changes`
            min_words: 65534,
            max_words: 65535,
            max_fragments: 0)

          columns = (column_names - %w{release_changes search_vector}).map { |column| "releases.\"#{column}\"" }
          columns.push excerpt.as("release_changes")
          where(query.conditions).select(*columns)
        end
      end



      def commit0
        super || commit_before.try(:sha)
      end

      def commit0=(sha)
        super; self.commit_before = identify_commit(sha)
      end

      def commit1
        super || commit_after.try(:sha)
      end

      def commit1=(sha)
        super; self.commit_after = identify_commit(sha)
      end

      def can_read_commits?
        (commit_before.present? || commit0 == Houston::NULL_GIT_COMMIT) && commit_after.present?
      end

      def environment_name=(value)
        super value.downcase
      end



      attr_reader :commit_not_found_error_message



      def released_at
        deploy ? deploy.completed_at : created_at
      end

      def release_date
        released_at.to_date
      end
      alias :date :release_date



      def name
        release_date.strftime("%A, %b %e, %Y")
      end

      def message=(value)
        super value.to_s.strip
      end

      def release_changes
        super.lines.map { |s| Houston::Releases::ReleaseChange.from_s(self, s) }
      end

      def release_changes=(changes)
        super changes.map(&:to_s).join("\n")
      end

      def release_changes_attributes=(params)
        self.release_changes = params.values
          .reject { |attrs| attrs["_destroy"] == "1" }
          .map { |attrs| Houston::Releases::ReleaseChange.new(self, attrs["tag_slug"], attrs["description"]) }
      end



      def build_changes_from_commits
        self.release_changes = commits
          .map { |commit| Houston::Releases::ReleaseChange.from_commit(self, commit) }
          .reject { |change| change.tag.nil? }
      end

      def load_commits!
        self.commits = project.commits.between(commit_before, commit_after)
      end



      def ignore?
        !project.show_release_notes_for?(environment_name)
      end

      def notification_recipients
        @notification_recipients ||= project.followers.unretired
      end



      def update_search_vector
        self.class.where(id: id).reindex!
      end

      def search_vector_should_change?
        (changed & %w{release_changes}).any?
      end


    private

      def identify_commit(sha)
        project.find_commit_by_sha(sha)
      rescue Houston::Adapters::VersionControl::CommitNotFound
        @commit_not_found_error_message = $!.message
        @commit_not_found_error_message << " in the repo \"#{project.repo}\"" if project
        nil
      rescue Houston::Adapters::VersionControl::InvalidShaError
        @commit_not_found_error_message = $!.message
        nil
      end

      # http://www.postgresql.org/docs/9.1/static/textsearch-controls.html#TEXTSEARCH-HEADLINE
      def self.ts_headline(column, query, options={})
        column = arel_table[column] if column.is_a?(Symbol)
        options = options.map { |(key, value)| "#{key.to_s.camelize}=#{value}" }.join(", ")
        tsquery = Arel.sql(query.send(:tsquery))
        Arel::Nodes::NamedFunction.new("ts_headline", [column, Arel::Nodes.build_quoted(tsquery), Arel::Nodes.build_quoted(options)])
      end

    end
  end
end
