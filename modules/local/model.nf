process RUN_MODEL {
    container 'nf-core/econ:0.02'

    tag { "${experiment} on ${id}" }
    label 'process_medium'

    input:
    tuple val(id), val(par_name), val(par_value), path(setup), val(experiment)
    path(nlogo)

    output:
    tuple val("${id}"), path("${id}_${experiment}.txt")

    script:
    """
    netlogo-headless.sh -Xmx${task.memory.mega}m --model ${nlogo} \
    --experiment "${experiment}" --table ${id}_${experiment}.txt \
    --setup-file ${setup} --threads ${task.cpus}
    """
}


