#!/bin/bash

input_file=$1
output_file=$2

# Create or clear the output file
> "$output_file"

while IFS=$'\t' read -r col1 col2 col3 rest; do
    # Check if the line starts with a # sign
    if [[ $col1 == \#* ]]; then
        echo -e "$col1\t$col2\t$col3\t$rest" >> "$output_file"
    else
        new_col3="${col1}_${col2}"
        echo -e "$col1\t$col2\t$new_col3\t$rest" >> "$output_file"
    fi
done < "$input_file"