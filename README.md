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

  [x] Decide which machine should exec the pipeline [see FHS](https://www.pathname.com/fhs/pub/fhs-2.3.html#SRVDATAFORSERVICESPROVIDEDBYSYSTEM)
  [x] After push, a chain of work is done
  [x] Task to rollback (on demand)
  [x] Plug all deployment tasks in git hooks
  [ ] Simplify deployment of git hooks
  [ ] Consider setting up a new machine where to deploy
  [x] Setting up git "server" on /srv/git/

* Create production environment

  [x] Decide which machine or user should be responsible for keeping up production environment
  [ ] Examine systemd integration [starting here](https://elixirforum.com/t/elixir-apps-as-systemd-services-info-wiki/2400) and [here](https://serverfault.com/questions/413397/how-to-set-environment-variable-in-systemd-service)
  [ ] Serve on port 80
  [ ] Task to install
  [ ] Task to uninstall
  [ ] Examine if mix releases are good enough
  [ ] Create system user for the application
  [ ] Use https
  [ ] log into /var/log/ directory
  [ ] assure data are written in /var/local/ directory
  [ ] change lib structure to clarify installations (e.g. in /usr/local/lib/)

* Hardining CI/CD pipeline

  [ ] mix format before commit
  [ ] mix test before commit
  [ ] mix test after integration

* Automate deployment to new development environment

  [ ] Simplify deployment of git hooks
  [ ] Create environment on each developer workstation
  [ ] Align dev and prod environments inside phx (leave all differences in environment vars)

* Check if some dependencies can be removed

  [ ] Fix gettext warning

* Plug in broker api
* Build fake trading system
* Display state of the trading system on the web interface
* Make aws effimere

## To Learn

* Configuration of phoenix project
* MinimumCD guides
* Phoenix guides
* Unix operating system and shell
* elixir json api client
* elixir ws client
* https
* broker api
* neovim

