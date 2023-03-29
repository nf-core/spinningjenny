process JOIN_FILES {
 
    container 'biocorecrg/amazonlinux-perlbrew-pyenv3-java:2'

    tag { "${id}" }
    
    input:
    tuple val(id), path(files)
    
    output:
    tuple val("${id}"), path("${id}_cat.txt")
    
    script:
    """
       head -n 7 ${files[0]} | tr -d "[]" > "${id}_cat.txt"
       for i in ${files}; do tail -n +8 \$i >> ${id}_cat.txt; done
 
    """
}


