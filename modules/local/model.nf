process runModel {
    container 'biocorecrg/econ:0.02'
   
 
    tag { "${experiment} on ${id}" }
    label 'big_cpus'
    
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


