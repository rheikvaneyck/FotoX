require 'rubygems'
require 'sinatra'
require 'active_record'
require 'haml'
require 'sass'
require 'uri'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  'db/fotos.sqlite'
)

class Foto < ActiveRecord::Base
  def next
    self.class.where("id > ?", id).first
  end

  def previous
    self.class.where("id < ?", id).last
  end
end

get '/' do
  @foto = Foto.first
  @foto = @foto.next
  redirect to("/foto/#{@foto.id}")
end

options '/' do
  response.headers["Allow"] = "HEAD,GET,OPTIONS"
  204
end

get '/foto/:id' do
	@id = params['id']
	@fotodb = "fotos.sqlite"
	@count = Foto.all().count
	if @id.to_i < 1 then 
		@id = 1
	elsif @id.to_i > @count.to_i then
		@id = @count
	end
	@foto = Foto.find_by_id(@id)
	if !@foto.nil? then
		@filename = @foto.filename
		@id = @foto.id
		@filepath = @foto.path
		@filepath_save = URI.escape("#{@filepath}/#{@filename}")
		@date = @foto.orig_time
		@address = @foto.address
		@size = as_size(@foto.size)
		@md5 = @foto.md5
		@duplicates = Foto.where(md5: @md5)
    @foto_next_id = @foto.id
    @foto_next_id = @foto.next.id if @foto.next
    @foto_previous_id = @foto.id
    @foto_previous_id = @foto.previous.id if @foto.previous
		haml :fotos
	end
end

get '/folder/:id' do
  @id = params['id']
  @foto = Foto.find_by_id(@id)
  if @foto then
    @fotos = Foto.where(path: @foto.path)
    @thumbnails = []
    @fotos.each do |f|
      @thumbnails.push [f.id, URI.escape("/raid1/shares/Fotos/thumbnails/#{f.md5[0..1]}/#{f.md5}.#{f.filetype}")]
    end
  end
  haml :folder
end

get '/top100' do
  @duplicates = Foto.find_by_sql("SELECT * FROM (SELECT id,COUNT(md5) AS md5_count,md5,filename,filetype,fullpath FROM fotos GROUP BY md5) WHERE md5_count > 1 ORDER BY md5_count DESC LIMIT 100") 
  haml :top100
end

get '/list_all_folders' do
  @fotos = Foto.select(:path, :id).group(:path)
  @folders = []
  @fotos.each do |f|
    @folders.push [f.id, f.path, Foto.where(path: f.path).count, Foto.where(path: f.path).sum(:size)]
  end
  haml :list_all_folders
end

get '/merge_folder/:id' do
  @id = params['id']
  @count = Foto.all().count
  if @id.to_i < 1 then 
    @id = Foto.first.id
  elsif @id.to_i > @count.to_i then
    @id = Foto.last.id
  end
  @foto = Foto.find_by_id(@id)
  if !@foto.nil? then
    @duplicates = Foto.where(md5: @foto.md5).where.not(path: @foto.path)
  end
  
  haml :merge_folder
end

get '/stylesheets/style.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :style
end

def as_size(s)
  units = %W(B KiB MiB GiB TiB)

  size, unit = units.reduce(s.to_f) do |(fsize, _), utype|
    fsize > 512 ? [fsize / 1024, utype] : (break [fsize, utype])
  end

  "#{size > 9 || size.modulo(1) < 0.1 ? '%d' : '%.1f'} %s" % [size, unit]
end