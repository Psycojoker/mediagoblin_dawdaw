#!dawdaw_template

import os
from dawdaw.states import pkg, postgres_user, postgres_database, service, cmd, user, file, git, virtualenv_mod as virtualenv, pip_state as pip
from dawdaw.utils import default, test

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
        virtualenv.managed(mediagoblin_git_dir, system_site_packages=True)
        cmd.run("./bin/python setup.py develop", cwd=mediagoblin_git_dir)

    mediagoblin_local_ini = file.managed(os.path.join(mediagoblin_git_dir, "mediagoblin_local.ini"), source="salt://mediagoblin/mediagoblin_local.ini")
    cmd.wait("./bin/gmg dbupdate", cwd=mediagoblin_git_dir, watch=[mediagoblin_local_ini])

    pip.installed("flup", pip_bin=os.path.join(mediagoblin_git_dir, "bin/pip"), runas=None)

pkg.installed("nginx")
service.running("nginx")
mediagoblin_nginx_config = file.managed("/etc/nginx/sites-enabled/mediagoblin.conf", source="salt://mediagoblin/nginx.conf")
cmd.wait("/etc/init.d/nginx reload", watch=[mediagoblin_nginx_config])

pkg.installed("supervisor")
service.running("supervisor")
mediagoblin_supervisor_conf = file.managed("/etc/supervisor/conf.d/mediagoblin.conf", source="salt://mediagoblin/supervisor.conf")
cmd.wait("supervisorctl update", watch=[mediagoblin_supervisor_conf])
