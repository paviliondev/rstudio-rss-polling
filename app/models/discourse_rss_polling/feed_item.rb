# frozen_string_literal: true

require_dependency 'feed_item_accessor'

module DiscourseRssPolling
  class FeedItem
    def initialize(rss_item, accessor = ::FeedItemAccessor)
      @accessor = accessor.new(rss_item)
    end

    def url
      url?(@accessor.link) ? @accessor.link : @accessor.element_content(:id)
    end

    def content
      content = nil

      CONTENT_ELEMENT_TAG_NAMES.each do |tag_name|
        break if content = @accessor.element_content(tag_name)
      end

      content&.force_encoding('UTF-8')&.scrub
    end

    def title
      unclean_title = @accessor.element_content(:title)&.force_encoding('UTF-8')&.scrub
      TextCleaner.clean_title(TextSentinel.title_sentinel(unclean_title).text).presence
    end

    def created_at
      @accessor.element_content(:pubDate)
    end

    private

    # The tag name's relative order implies its priority.
    CONTENT_ELEMENT_TAG_NAMES = %i[
      content_encoded
      content
      description
      summary
    ]

    def url?(link)
      link.present? && link =~ /^https?\:\/\//
    end
  end
end
