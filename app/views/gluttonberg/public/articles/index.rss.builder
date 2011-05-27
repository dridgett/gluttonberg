xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @blog.name
    xml.description @blog.description
    xml.link blog_url(@blog.slug)

    for article in @articles
      xml.item do
        xml.title article.title
        xml.description article.excerpt || article.body
        xml.pubDate article.created_at.to_s(:rfc822)
        xml.link blog_article_path(@blog.slug, article.slug)
        xml.guid blog_article_path(@blog.slug, article.slug)
      end
    end
  end
end