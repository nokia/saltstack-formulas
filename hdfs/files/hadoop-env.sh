# JAVA_HOME is required by HADOOP_HOME/bin/*.sh scripts
# detect JAVA_HOME and PATH
. /etc/profile
. /etc/environment

export HADOOP_LOG_DIR={{ log_dir }}

export HADOOP_SSH_OPTS="-o StrictHostKeyChecking=no"

export JAVA_HOME
export PATH=$HADOOP_HOME/bin:$JAVA_HOME/bin:$PATH
