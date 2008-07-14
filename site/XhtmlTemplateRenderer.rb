require 'ZenWeb/HtmlRenderer'

=begin

= Class HtmlTemplateRenderer

Generates a consistant HTML page header and footer, including a
navigation bar, title, subtitle, and appropriate META tags.

=== Methods

=end

class XhtmlTemplateRenderer < HtmlRenderer

=begin

--- HtmlTemplateRenderer#render(content)

    Renders a standardized HTML header and footer. This currently also
    includes a navigation bar and a list of subpages, which will
    probably be broken out to their own renderers soon.

    Metadata variables used:

    + author
    + banner - graphic at the top of the page, usually a logo
    + bgcolor - defaults to not being defined
    + copyright
    + description
    + dtd (default: 'DTD HTML 4.0 Transitional')
    + email - used in a mailto in metadata
    + keywords
    + rating (default: 'general')
    + stylesheet - reference to a CSS file
    + style - CSS code directly (for smaller snippets)
    + subtitle
    + title (default: 'Unknown Title')
    + icbm - longitude and latitude for geourl.org
    + icbm_title - defaults to the page title

=end

  def render(content)
    author      = @document['author']
    banner      = @document['banner']
    bgcolor     = @document['bgcolor']
    dtd		= @document['dtd'] || 'DTD HTML 4.0 Transitional'
    copyright   = @document['copyright']
    description = @document['description']
    email       = @document['email']
    keywords    = @document['keywords']
    rating      = @document['rating'] || 'general'
    stylesheet  = @document['stylesheet']
    subtitle    = @document['subtitle']
    title       = @document['title'] || 'Unknown Title'
    icbm        = @document['icbm']
    icbm_title  = @document['icbm_title'] || @document['title']
    charset     = @document['charset']
    style       = @document['style']

    titletext   = @document.fulltitle

    # TODO: iterate over a list of metas and add them in one nicely organized block

    # header
    push([
	   '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">',
	   "<head>\n",
	   "<title>#{titletext}</title>\n",
	   stylesheet ? "<link rel=\"STYLESHEET\" href=\"#{stylesheet}\" type=\"text/css\" title=\"#{stylesheet}\">\n" : [],
	   style ? "<style>\n#{style}\n</style>" : [],
	   "</head>\n",
	   "<body>\n"
	 ])

    self.navbar

    if banner then
      push("<img src=\"#{banner}\" /><br />\n")
      unless (subtitle) then
	push("<h3>#{title}</h3>\n")
      end
    else
      push("<h1>#{title}</h1>\n")
    end

    push([
	   subtitle ? "<h2>#{subtitle}</h2>\n" : [],
	   "<hr />\n\n",
	   content,
	   "<hr />\n\n",
	 ])

    self.navbar

    push("\n</body>\n</html>\n")

    return self.result
  end

=begin

--- HtmlTemplateRenderer#navbar

    Generates a navbar that contains a link to the sitemap, search
    page (if any), and a fake "breadcrumbs" trail which is really just
    a list of all of the parent titles up the chain to the top.

=end

  def navbar

    sep = " / "
    search  = @website["/Search.html"]

    push([
	   "<p class=\"navbar\">\n",
	   "<a href=\"#{@sitemap.url}\">Sitemap</a>",
	   search ? " | <a href=\"#{search.url}\"><em>Search</em></a>" : [],
	   " || ",
	 ])

    path = []
    current = @document
    while current and current != current.parent do
      current = current.parent
      path.unshift(current) if current
    end

    push([
	   path.map{|doc| ["<a href=\"#{doc.url}\">#{doc['title']}</a>\n", sep]},
	   @document['title'],
	   "</p>\n",
	 ])

    return []
  end

end

