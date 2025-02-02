require_relative "spec_helper"

describe "A PHP application" do
	context "with a composer.lock generated by an old version of Composer", :stack => "heroku-20" do
		it "builds using Composer 1.x and prints a notice" do
			new_app_with_stack_and_platrepo('test/fixtures/composer/basic_lock_oldv1').deploy do |app|
				expect(app.output).to match(/No Composer platform-api-version recorded/)
				expect(app.output).to match(/- composer \(1/)
				expect(app.output).to match(/Composer version 1/)
			end
		end
	end
	context "with a composer.lock generated by a late version 1 of Composer", :stack => "heroku-20" do
		it "builds using Composer 1.x" do
			new_app_with_stack_and_platrepo('test/fixtures/composer/basic_lock_v1').deploy do |app|
				expect(app.output).to match(/- composer \(1/)
				expect(app.output).to match(/Composer version 1/)
			end
		end
	end
	context "with a composer.lock generated by version 2.2 of Composer" do
		it "builds using Composer 2.2" do
			new_app_with_stack_and_platrepo('test/fixtures/composer/basic_lock_v2lts').deploy do |app|
				expect(app.output).to match(/- composer \(2\.2\./)
				expect(app.output).to match(/Composer version 2\.2\./)
			end
		end
	end
	context "with a composer.lock generated by version 2.3 of Composer" do
		it "builds using Composer 2.3 or later" do
			new_app_with_stack_and_platrepo('test/fixtures/composer/basic_lock_v2').deploy do |app|
				expect(app.output).to match(/- composer \(2\.([3-9]|\d{2,})\./)
				expect(app.output).to match(/Composer version 2\.([3-9]|\d{2,}\.)/)
			end
		end
	end
	context "with a composer.lock generated by a future version 2 of Composer" do
		it "builds using Composer 2.3 or later" do
			new_app_with_stack_and_platrepo('test/fixtures/composer/basic_lock_v2.999').deploy do |app|
				expect(app.output).to match(/- composer \(2\.([3-9]|\d{2,})\./)
				expect(app.output).to match(/Composer version 2\.([3-9]|\d{2,}\.)/)
			end
		end
	end
	context "with only an index.php" do
		it "builds using Composer 2.2" do
			new_app_with_stack_and_platrepo('test/fixtures/default').deploy do |app|
				expect(app.output).to match(/- composer \(2\.2\./)
				expect(app.output).to match(/Composer version 2\.2\./)
			end
		end
	end
	context "with a malformed COMPOSER_AUTH env var" do
		['v1', 'v2'].each do |cv|
			next unless cv == "v2" or "heroku-20" == ENV['STACK']
			it "the app still boots" do
				new_app_with_stack_and_platrepo("test/fixtures/composer/basic_lock_#{cv}", run_multi: true).deploy do |app|
					['heroku-php-apache2', 'heroku-php-nginx'].each do |script|
						retry_until retry: 3, sleep: 5 do
							out = app.run("#{script} -F composer.lock", :heroku => {:env => "COMPOSER_AUTH=malformed"}) # prevent FPM from starting up using an invalid config, that way we don't have to wrap the server start in a `timeout` call
							expect(out).to match(/Starting php-fpm/) # we got far enough (until FPM spits out an error)
						end
					end
				end
			end
		end
	end
end
