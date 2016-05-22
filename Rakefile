task :default do
  sh 'rspec spec'
end

desc "Prepare archive for deployment"
task :archive do
  sh 'zip -r ~/ember_tools.zip autoload/ doc/ember_tools.txt plugin/'
end
