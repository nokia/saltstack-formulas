
def log_dir(name):
    return "{0}/{1}/log".format(__pillar__['system']['var'], name)

def work_dir(name):
    return "{0}/{1}/work".format(__pillar__['system']['var'], name)

def custom_dir(name, dirname):
    return "{0}/{1}/{2}".format(__pillar__['system']['var'], name, dirname)

def home_dir(name):
    return "{0}/{1}".format(__pillar__['system']['lib'], name)
