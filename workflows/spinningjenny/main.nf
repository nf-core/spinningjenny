/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
//WorkflowSpinningjenny.initialise(params, log)


// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [ params.input ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input values not specified!' }
if (params.template) { ch_template = file(params.template) } else { exit 1, 'Input xml template not specified!' }
if (params.batches) { n_batches = params.batches } else { exit 1, 'Input number of batches not specified!' }
if (params.nlogo) { ch_nlogo = params.nlogo } else { exit 1, 'You need to specify the nlogo file!' }



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
//include { INPUT_CHECK } from '../subworkflows/local/input_check'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { XML_MOD }    from '../../modules/local/xmlmod.nf'
include { RUN_MODEL }  from '../../modules/local/model.nf'
include { JOIN_FILES } from '../../modules/local/joinfiles.nf'
include { MAKE_PLOT }  from '../../modules/local/rplot.nf'

include { softwareVersionsToYAML           } from '../../subworkflows/nf-core/utils_nfcore_pipeline'


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow SPINNINGJENNY {

    take:
    ch_samplesheet // channel: samplesheet read in from --input
    // Create channels for input values

    main:

    Channel
        .from(ch_input.readLines())
        .map { line ->
            list = line.split("\t")
                if (list.length <2) {
                    error "ERROR!!! Values file has to be tab separated\n"
                }
                if (list[0]!= "") {
                    param_name = list[0]
                initial_val = list[1]
                final_val = list[2]
                step_val = list[3]
                [ param_name, initial_val, final_val, step_val ]
            }
        }.set{ pipe_params}


    Experiments = Channel.of( "testing1" )

    pipe_params.map {
        def BigDecimal start = Float.parseFloat(it[1])
        def BigDecimal fin = Float.parseFloat(it[2])
        def BigDecimal step = Float.parseFloat(it[3])
        def ranges = []
        for (i = fin; i > start; i-=step) {
            ranges.push(i)
        }
        ranges.push(start)
        [it[0], ranges]

    }.transpose().set{reshaped_pars}

    n_batches = Channel.from( 1..params.batches )


    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //

    xml_files = XML_MOD (reshaped_pars, ch_template)
    xml_files.combine(Experiments).combine(n_batches).map{
            ["${it[0]}__${it[5]}", it[1], it[2], it[3], it[4]]
    }.set{data_for_model}
    res_model = RUN_MODEL(data_for_model, ch_nlogo)
    res_model.map{
            def ids = it[0].split("__")
            [ids[0], it[1]]
    }.groupTuple().set{files_pieces}

    concat_res = JOIN_FILES(files_pieces)
    out = MAKE_PLOT(concat_res)

    emit:
    out
}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
