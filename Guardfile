guard :rspec, failed_mode: :focus, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})               { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/soulheart/(.+)\.rb$})     { |m| "spec/soulheart/#{m[1]}_spec.rb" }
end
