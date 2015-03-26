import time

def vps():
    env.hosts = ['apps.myvps.com']
    env.user = 'app'
    env.dbname = 'blog'
    env.dbuser = 'blogger'
    env.dbpass = 'password'

def backup():
    require('hosts', provided_by=[vps])
    require('dbname')
    require('dbuser')
    require('dbpass')

    date = time.strftime('%Y%m%d%H%M%S')
    fname = '/tmp/%(database)s-backup-%(date)s.xml.gz' % {
        'database': env.dbname,
        'date': date,
    }

    if exists(fname):
        run('rm "%s"' % fname)

    run('mysqldump -u %(username)s -p%(password)s %(database)s --xml | '
        'gzip > %(fname)s' % {'username': env.dbuser,
                              'password': env.dbpass,
                              'database': env.dbname,
                              'fname': fname})

    get(fname, os.path.basename(fname))
    run('rm "%s"' % fname)