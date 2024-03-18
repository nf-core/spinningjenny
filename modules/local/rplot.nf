process MAKE_PLOT {

    container 'biocorecrg/econ_r:0.1'

    errorStrategy = 'ignore'

    tag { id }

    input:
    tuple val(id), path(res)

    output:
    tuple val(id), path("*.pdf")

    script:
    """
    make_graph.R -input ${res} -output ${id}
    """
}

