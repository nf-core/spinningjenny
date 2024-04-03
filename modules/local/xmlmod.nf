process XML_MOD {
    container 'biocontainers/python:3.12'

    tag { "${par_name} on ${par_value}" }

    input:
    tuple val(par_name), val(par_value)
    path(setup)


    output:
    tuple val("${par_name}_${par_value}"), val(par_name), val(par_value),  path("${par_name}_${par_value}_${setup}")

    script:
    """
    make_xml.py -t ${setup} -n ${par_name}  -v ${par_value} -o ${par_name}_${par_value}_${setup}
    """
}
