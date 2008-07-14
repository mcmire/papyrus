#!/usr/local/bin/ruby

require 'ZenWeb'

data_dir = "src"
html_dir = "html"
sitemap  = "/SiteMap.html"
url      = "/"

website = ZenWebsite.new(sitemap, data_dir, html_dir)
website.renderSite
