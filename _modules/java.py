

def alternatives_install_cmd(jdk_home):
    bin_cmds = __pillar__['java']['bin_cmds']
    alts = ["update-alternatives --install /usr/bin/{0} {0} {2}/{1} 1061".format(
        alt_cmd.split("/")[len(alt_cmd.split("/")) - 1], alt_cmd, jdk_home) for alt_cmd in bin_cmds]
    return str.join(" && ", alts)


def alternatives_set_cmd(jdk_home):
    bin_cmds = __pillar__['java']['bin_cmds']
    alts = ["update-alternatives --set {0} {2}/{1}".format(alt_cmd.split("/")[len(alt_cmd.split("/")) - 1], alt_cmd,
                                                           jdk_home) for alt_cmd in bin_cmds]
    return str.join(" && ", alts)
