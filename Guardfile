# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', cli: '--color --format nested' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(?:\w+/)*(.+)\.rb$})           {|m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end


guard 'cucumber', cli: '--format pretty --tags ~@slow' do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})          { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end
