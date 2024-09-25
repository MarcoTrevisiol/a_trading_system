# ATradingSystem

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## TODO

* Automate deployment to staging environment into the build system
  [ ] Decide which machine should exec the pipeline
  [ ] Task to install
  [ ] Task to test
  [ ] Task to uninstall
  [ ] Task to revert
  [ ] Plug all deployment tasks in git hooks
  [ ] Simplify deployment of git hooks
  [ ] Consider setting up a new machine where to deploy
* Create production environment
  [ ] Decide which machine or user should be responsible for keeping up production environment
  [ ] Examine systemd integration
  [ ] Serve on port 80
  [ ] Tasks similar to staging environment
  [ ] Examine if mix releases are good enough
  [ ] Create system user for the application
  [ ] Use https
* Hardining CI/CD pipeline
  [ ] mix format before commit
  [ ] mix test before commit
  [ ] mix test after integration
* Automate deployment to new development environment
  [ ] Simplify deployment of git hooks
  [ ] Create environment on each developer workstation
* Check if some dependencies can be removed
* Plug in broker api
* Build fake trading system
* Display state of the trading system on the web interface

## To Learn

* Configuration of phoenix project
* MinimumCD guides
* Phoenix guides
* Unix operating system and shell
* elixir json api client
* elixir ws client
* https
* broker api

