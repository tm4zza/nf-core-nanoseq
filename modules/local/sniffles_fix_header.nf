process SNIFFLES_FIX_HEADER {
    tag "$meta.id"
    label 'process_high'
    
    input:
    tuple val(meta), path(sv_calls)

    output:
    tuple val(meta), path("*_fixed.vcf"), emit: sv_calls_fixed
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    VERSION="1.0.0"
    """
    awk '
    BEGIN { added = 0 }
    {
        # Check if the line already exists
        if ($0 == "##FILTER=<ID=STRANDBIAS,Description=\"Strand bias\">") {
            added = 1
        }
        # If we encounter a line in the ##FILTER section and it doesn\'t exist yet
        if (!added && /^##FILTER/) {
            # Print the new line just before exiting the ##FILTER section
            print "##FILTER=<ID=STRANDBIAS,Description=\"Strand bias\">"
            added = 1
        }
        # Print the current line
        print $0
    }
    END {
        # If no ##FILTER section existed, append the line to the header
        if (!added) {
            print "##FILTER=<ID=STRANDBIAS,Description=\"Strand bias\">"
        }
    }' ${sv_calls} > ${ncbi_annotation.baseName}_fixed.vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sniffles fix header: ${VERSION})
    END_VERSIONS
    """
}

