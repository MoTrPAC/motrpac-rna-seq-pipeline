{
    "__default__" :
    {
        "nCPUs"     : "1",
        "time"      : "24:00:00",
        "mem"       : "6G",
        "account"   : "prj_motrpac",
        "name"      : "{rule}.{wildcards.viallabel}",
        "mail"      : "FAIL",
        "output"    : "log/cluster/{rule}.{wildcards.viallabel}.out"
    },
    "star_second_pass" :
    {
        "nCPUs"     : "6",
        "mem"       : "48G"
    },
    "junc_to_intron_cluster" :
    {
        "name"      : "{rule}",
        "output"    : "log/cluster/{rule}.out"
    },
    "make_groups" :
    {
        "name"      : "{rule}",
        "output"    : "log/cluster/{rule}.out"
    },
    "ds" :
    {
        "name"      : "{rule}",
        "output"    : "log/cluster/{rule}.out",
        "nCPUs"     : "6"
    },
    "plot" :
    {
        "name"      : "{rule}",
        "output"    : "log/cluster/{rule}.out"
    }
}
