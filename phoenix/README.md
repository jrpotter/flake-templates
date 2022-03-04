# hello-world

## Configuration

Before you are able to start the server, you must update `SECRET_KEY_BASE` and
`SECRET_SALT` within `config/config.exs`. The commands used to generate these
secrets are present within the currently assigned secrets.

The default Phoenix server also expects to connect to a Postgres instance. To
create one, run the following:

```bash
pg_ctl init
pg_ctl start
createuser postgres --superuser
createdb hello_world_dev
```

Stop the database by running

```bash
pg_ctl stop
```

These commands are provided by [flake-templates](https://github.com/jrpotter/flake-templates),
allowing us to create a local db with name corresponding to the exported
`DB_NAME` value in the `.envrc` file.

## Building

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `npm install` inside the `assets` directory
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
