require "rubygems"
require "bundler/setup"
require "stringex"

task :build do 
     system "jekyll build"
end

task :clean do 
     rm_rf ["_site"]
end

desc "begin a new blog post"
task :new_blog, :title do |t, args|
     if args.title
        title = args.title
     else
        title = get_stdin("Enter a title for your post: ")
     end

     filename = "_posts/blog/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.md"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "author: Chris Woodall"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "comments: true"
    post.puts "categories: blog"
    post.puts "---"
  end
end