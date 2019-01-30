version 1.0

task AppendToStringArray {
    input {
        Array[String] array
        String string
    }

    command {
        echo "~{sep='\n' array}
        ~{string}"
    }

    output {
        Array[String] outArray = read_lines(stdout())
    }

    runtime {
        memory: 1
    }
}

# This task will fail if the MD5sum doesn't match the file.
task CheckFileMD5 {
    input {
        File file
        File md5
    }

    command {
        set -e -o pipefail
        MD5SUM=$(md5sum ~{file} | cut -d ' ' -f 1)
        MD5SUM_CORRECT=$(cat ~{md5} | grep ~{basename(file)} | cut -d ' ' -f 1)
        [ $MD5SUM = $MD5SUM_CORRECT ]
    }
}

task ConcatenateTextFiles {
    input {
        Array[File] fileList
        String combinedFilePath
        Boolean unzip = false
        Boolean zip = false
    }

    # When input and output is both compressed decompression is not needed
    String cmdPrefix = if (unzip && !zip) then "zcat " else "cat "
    String cmdSuffix = if (!unzip && zip) then " | gzip -c " else ""

    command {
        set -e -o pipefail
        ~{"mkdir -p $(dirname " + combinedFilePath + ")"}
        ~{cmdPrefix} ~{sep=' ' fileList} ~{cmdSuffix} > ~{combinedFilePath}
    }

    output {
        File combinedFile = combinedFilePath
    }

    runtime {
        memory: 1
    }
}

task CreateLink {
    # Making this of type File will create a link to the copy of the file in the execution
    # folder, instead of the actual file.
    input {
        String inputFile
        String outputPath
    }

    command {
        ln -sf ~{inputFile} ~{outputPath}
    }

    output {
        File link = outputPath
    }
}

# DEPRECATED. USE BUILT-IN FLATTEN FUNCTION
# task FlattenStringArray {}
# Commented out to let pipelines that depend on this fail.

task MapMd5 {
    input {
        Map[String,String] map
    }

    command {
        cat ~{write_map(map)} | md5sum - | sed -e 's/  -//'
    }

    output {
        String md5sum = read_string(stdout())
    }

    runtime {
        memory: 1
    }
}


task ObjectMd5 {
    input {
        Object the_object
    }

    command {
        cat ~{write_object(the_object)} |  md5sum - | sed -e 's/  -//'
    }

    output {
        String md5sum = read_string(stdout())
    }

    runtime {
        memory: 1
    }
}

task StringArrayMd5 {
    input {
        Array[String] stringArray
    }

    command {
        set -eu -o pipefail
        echo ~{sep=',' stringArray} | md5sum - | sed -e 's/  -//'
    }

    output {
        String md5sum = read_string(stdout())
    }

    runtime {
        memory: 1
    }
}

task YamlToJson {
    input {
        File yaml
        String outputJson = basename(yaml, "\.ya?ml$") + ".json"
    }

    command {
        set -e
        mkdir -p $(dirname ~{outputJson})
        python <<CODE
        import json
        import yaml
        with open("~{yaml}", "r") as input_yaml:
            content = yaml.load(input_yaml)
        with open("~{outputJson}", "w") as output_json:
            json.dump(content, output_json)
        CODE
    }
    output {
        File json = outputJson
    }
}

struct Reference {
    File fasta
    File fai
    File dict
}

struct IndexedVcfFile {
    File file
    File index
    File? md5sum
}

struct IndexedBamFile {
    File file
    File index
    File? md5sum
}

struct FastqPair {
    File R1
    File? R1_md5
    File? R2
    File? R2_md5
}

struct CaseControl {
    String inputName
    IndexedBamFile inputFile
    String controlName
    IndexedBamFile controlFile
}

struct CaseControls {
    Array[CaseControl] caseControls
}
