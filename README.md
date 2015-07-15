# GitHub

The GitHub app provides details of a particular user after that user has logged in. It is an example of a Livestax App using OAuth.

## Contributing

We'd love to get contributions from you!
For instructions on how to get set up quickly, follow the installation instructions below.
Once you're up and running, take a look at the [Contribution Document](https://github.com/livestax/app-github/blob/master/CONTRIBUTING.md) to see how to get your changes merged in.

### Installation

1. [Fork then] clone the repository
  * `git clone git@github.com:livestax/app-github.git`
2. Install the Ruby Gem dependencies
  * `bundle`
3. Copy the `env` example and amend
  * `cp .env.example .env`
4. Start the server
  * `shotgun`
5. Open the app in the browser
  * `http://127.0.0.1:9393`

### Running the tests

```bash
bundle exec rspec
```

## License

Code released under the MIT license. Docs released under Creative Commons.
