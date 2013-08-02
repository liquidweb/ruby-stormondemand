A Ruby client library for the Storm On Demand Cloud API.

# Installation
Install the gem:

    gem install storm

Alternatively, you can add it to your project's Gemfile:

    gem 'storm'

# Usage
Require the Storm library:

    require 'Storm'

Set your API username and password:

    Storm::Account::Auth.username = 'username'
    Storm::Account::Auth.password = 'password'

If you would like to use an API token instead of username/password once you've authenticated using a username and password:

    Storm::Account::Auth.token

This will fetch a new token and use it for all subsequent API requests.

The storm library follows a structure similar to the [Storm API documentation](https://www.stormondemand.com/api/docs/v1).

For instance, you can create a new server like this:

    config = Storm::Config.list[:items].first
    template = Storm::Template.list[:items].first
    server = Storm::Server.create config, 'www.yoursite.com', 'root-password', :template => template

In the previous example we're simply using the first available server configuration and template.

To destroy it:

    server.destroy

# Contibuting

## Building using RubyGems

### Build the gem:

    gem build storm.gemspec

### Installing:

    gem install storm.gem-0.0.3.beta1

## Using Bundler

### Developing storm alongside your project by adding it to your Gemfile
This is also known as using an unpacked gem. In your Gemfile add:

    gem 'storm', :path => './path/to/storm_src'

 This has a few advantages over using RubyGems:

 - Bundler will use the dependencies declared in the gemspec and ensure they're installed.
 - Changes to the storm source will be reflected in your project without the build/install step.

## Documentation
[YARD](http://yardoc.org/) is used to generate documentation.

Generate the documentation:

    yard

Start the local documentation server:

    yard server

To view the documentation open your browser and go to:

    http://localhost:8808

# Changelog

#### 0.0.3

- [x] Added runtime dependencies to gemspec.
- [x] Added homepage and license to gemspec.
- [x] Updated developer documentation.

# Copyright and License

Copyright 2013 Liquid Web, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
