# RUN in Gimli with IP=0.0.0.0 ruby hear-app.rb

require 'sinatra'
require 'json'
require 'securerandom' #make id numbers
# require 'rqrcode'

configure do
  set :port, ENV['PORT']
  set :bind, ENV['IP']
end

before do
  @feeds = JSON.parse(File.read("database.json"))
end

get '/' do
  erb :index
end

get '/new' do
  @id = SecureRandom.hex(4)
  @feed = {
    "id"          => @id,
    "title"       => "title of the feed",
    "desc"        => "description ",
    "feed_type"   => "feed_type: web/pod/vid",
    "feed_url"    => "feed_url (http://feed.rss)",
    "site_url"    => "site_url (http://site.com)",
    "active"      => "active (true or false)",
    "qr_url"      => "qr_url (this is a future feature)",
    "updated_at"  => Time.now,
  }
  @feeds.push(@feed)
  File.open("database.json", "w") do |fh|
    puts "NEW RECORD TO DATABASE, ---- #{@feeds} "
    fh.write @feeds.to_json
  end
  redirect to("/#{@id}/edit?new=true")
end

get '/:id' do
  @ndx = params[:id]
  @feed = @feeds.select{|f| f['id'] == @ndx}.first
  erb :show
end

get '/:id/edit' do
  @ndx = params[:id]
  @feed = @feeds.select{|f| f['id'] == @ndx}.first
  erb :edit
end

post '/:id' do
  @ndx = params[:id]
  @feed = @feeds.select{|f| f['id'] == @ndx}.first
  @up = {
    "id"          => params[:id],
    "title"       => params[:title],
    "desc"        => params[:desc],
    "feed_type"   => params[:feed_type],
    "feed_url"    => params[:feed_url],
    "site_url"    => params[:site_url],
    "active"      => params[:active],
    "qr_url"      => params[:qr_url],
    "updated_at"  => Time.now,
  }
  @feeds.map! do |element|
    if element['id'] == @ndx
      @up
    else
      element  # is Ruby smart enough to just skip over these?
    end
  end
  File.open("database.json", "w") do |fh|
    puts "WRITING TO DATABASE, EH? ---- #{@feeds} "
    fh.write @feeds.to_json
  end
  @feeds = JSON.parse(File.read("database.json"))
  redirect to("/#{@ndx}")
end

__END__


@@ index
<p><strong>Hungry Earworm</strong> - a list of RSS feeds</p>
<ul>
  <% @feeds.each_with_index do |f, ndx| %>
    <li>
      <strong><a href="/<%= f['id'] %>"><%= f['title'] %></a></strong>
      <%= f['feed_url'] %>
      <%= f['active'] ? "[active]" : "[asleep]" %>
      <a href='/<%= f['id'] %>/edit'>edit</a>
    </li>
  <% end %>
</ul>


@@ edit
<style>.r{text-align:right;padding-right:1em;}</style>
<p><strong><a href='/'>Back</a></strong></p>
<table cellpadding="1" cellspacing="0" border="0">
<form action="/<%= @feed['id'] %>" method="POST">
      <tr><td class='r'><code>id:        </code></td><td><%= @feed['id'] %></td></tr>
      <tr><td class='r'><code>title:     </code></td><td><input type="text" name="title" value="<%= @feed['title'] %>"></td></tr>
      <tr><td class='r'><code>desc:      </code></td><td><input type="text" name="desc" value="<%= @feed['desc'] %>"></td></tr>
      <tr><td class='r'><code>feed_type: </code></td><td><input type="text" name="feed_type" value="<%= @feed['feed_type'] %>"></td></tr>
      <tr><td class='r'><code>feed_url:  </code></td><td><input type="text" name="feed_url" value="<%= @feed['feed_url'] %>"></td></tr>
      <tr><td class='r'><code>site_url:  </code></td><td><input type="text" name="site_url" value="<%= @feed['site_url'] %>"></td></tr>
      <tr><td class='r'><code>active:    </code></td><td><input type="text" name="active" value="<%= @feed['active'] %>"></td></tr>
      <tr><td class='r'><code>qr_url:    </code></td><td><input type="text" name="qr_url" value="<%= @feed['qr_url'] %>"></td></tr>
      <tr><td class='r'><code>updated_at:</code></td><td><%= @feed['updated_at'] %> </td></tr>
      <tr><td>&nbsp;</td><td class='r'><input type="submit"> </td></tr>
</form>
</table>


@@ show
<style>.r{text-align:right;padding-right:1em;}</style>
<p><strong><a href='/'>Back</a></strong></p>
<table cellpadding="1" cellspacing="0" border="0">
<tr><td class='r'>id:</td><td><%= @feed['id'] %></td></tr>
<tr><td class='r'>title:</td><td><%= @feed['title'] %></td></tr>
<tr><td class='r'>desc:</td><td><%= @feed['desc'] %></td></tr>
<tr><td class='r'>feed_type:</td><td><%= @feed['feed_type'] %></td></tr>
<tr><td class='r'>feed_url:</td><td><%= @feed['feed_url'] %></td></tr>
<tr><td class='r'>site_url:</td><td><%= @feed['site_url'] %></td></tr>
<tr><td class='r'>active:</td><td><%= @feed['active'] %></td></tr>
<tr><td class='r'>qr_url:</td><td><%= @feed['qr_url'] %></td></tr>
<tr><td class='r'>updated_at:</td><td><%= @feed['updated_at'] %></td></tr>
<tr><td>&nbsp;</td><td class='r'><a href='/<%= @feed['id'] %>/edit'>edit</a></td></tr>
</table>
