#!dawdaw_template

import os
from dawdaw.states import pkg, postgres_user, postgres_database, service, cmd, user, file, git, virtualenv_mod
from dawdaw.utils import debug, default, test

debug()

cmd.run("update-locale LC_ALL=en_US.UTF-8 && export LC_ALL=en_US.UTF-8")  # ensure that we create the db with the correct encoding

pkg.installed("dependancies", pkgs=["git-core", "python", "python-dev", "python-lxml", "python-imaging", "python-virtualenv", "postgresql", "postgresql-client", "python-psycopg2"])

service.running("postgresql")

postgres_user.present("root")  # for debugging

postgres_user.present("mediagoblin")
postgres_database.present("mediagoblin")

user.present("mediagoblin")

with default(user="mediagoblin", group="mediagoblin", runas="mediagoblin"):
    mediagoblin_dir = "/srv/mediagoblin.example.org"
    mediagoblin_git_dir = os.path.join(mediagoblin_dir, "mediagoblin")
    file.directory(mediagoblin_dir, makedirs=True)
    if not test("ls %s" % mediagoblin_git_dir):
        git.latest("git://gitorious.org/mediagoblin/mediagoblin.git", target=mediagoblin_git_dir)
        cmd.run("git submodule init && git submodule update", cwd=mediagoblin_git_dir)

    if not test("ls %s" % os.path.join(mediagoblin_git_dir, "bin")):
        virtualenv_mod.managed(mediagoblin_git_dir)
        cmd.run("./bin/python setup.py develop", cwd=mediagoblin_git_dir)