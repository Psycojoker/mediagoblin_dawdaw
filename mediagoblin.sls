#!dawdaw_template

from dawdaw.states import pkg, postgres_user, service, cmd

cmd.run("update-locale LC_ALL=en_US.UTF-8 && export LC_ALL=en_US.UTF-8")  # ensure that we create the db with the correct encoding

pkg.installed("dependancies", pkgs=["git-core", "python", "python-dev", "python-lxml", "python-imaging", "python-virtualenv", "postgresql", "postgresql-client", "python-psycopg2"])

service.running("postgresql")

postgres_user.present("mediagoblin")
postgres_user.present("root")  # for debugging
