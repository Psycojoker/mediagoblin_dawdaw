#!dawdaw_template

from dawdaw.states import pkg, postgres_user, service

pkg.installed("dependancies", pkgs=["git-core", "python", "python-dev", "python-lxml", "python-imaging", "python-virtualenv", "postgresql", "postgresql-client", "python-psycopg2"])

service.running("postgresql")

postgres_user.present("mediagoblin")
