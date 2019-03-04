java -Dconfig.file=google.conf -jar /Users/archanaraja/work/tools/cromwell-34.jar run mark_duplicates/markduplicates.wdl -i mark_duplicates/markduplicates_input.json

# Run Locally in mark_duplicates folder
java -jar ~/cromwell/cromwell-36.jar run markduplicates.wdl -i markduplicates_input.json

# Run Cloud in mark_duplicates folder
java -Dconfig.file=../google.conf -jar ~/cromwell/cromwell-36.jar run markduplicates.wdl -i markduplicates_input.json
