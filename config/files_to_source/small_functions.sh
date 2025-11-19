# Function to open CSV files in a pretty table 
function csv {
    perl -pe 's/((?<=,)|(?<=^)),/ ,/g;' "$@" | column -t -s, | less  -F -S -X -K
}

# same for TSV
function tsv {
    perl -pe 's/((?<=\t)|(?<=^))\t/ \t/g;' "$@" | column -t -s $'\t' | less  -F -S -X -K
}

# function to knit RMarkdown document
function knit() {
    R -e "rmarkdown::render('$1')"
}

function sacct_formatted {
    sacct --format="JobID,CPUTime,Elapsed,State,MaxRSS" | awk '
    BEGIN { 
        # Print the header with the new column order
        printf "%-20s %-15s %-15s %-15s %-15s\n", "JobID", "CPUTime", "Elapsed", "State", "MaxRSS"
    }
    NR > 1 && $1 !~ /\.ex+/ { 
        # Handle missing MaxRSS
        if ($5 == "" || $5 == "0") {
            $5 = "NA"  # Replace missing or zero MaxRSS with "NA"
        } else {
            split($5, rss, "K")  # Split MaxRSS into value and unit (assuming KB)
            if ($5 ~ /K/) { 
                $5 = sprintf("%.2f GB", rss[1] / 1024 / 1024)  # Convert KB to GB
            }
        }
        # Print rows with the new column order
        printf "%-20s %-15s %-15s %-15s %-15s\n", $1, $2, $3, $4, $5
    }'
}

# Find text in any file (ft "mytext" *.txt)
function ft { find . -name "$2" -exec grep -il "$1" {} \;; }

# tail the last created file in ./logs/slurm_logs
tlf() {
    latest_log=$(ls -t logs/slurm_log/* 2>/dev/null | head -n1)
    if [[ -n "$latest_log" ]]; then
        tail -f "$latest_log"
    else
        echo "No log files found in logs/slurm_log/"
    fi
}

# Make and Change Directory
# from https://gist.github.com/kallmanation/2027bb23242e59cb90141c803ffe2703
mkdircd() { mkdir "$@" 2> >(sed s/mkdir/mcd/ 1>&2) && cd "$_"; }

# Simple CLI calculator
# from https://gist.github.com/kallmanation/fa535dc9da0cdadaaaf7c9d2630e5e99
c() { echo "$@" | bc -l; }

# Compute the mean/average of a list of numbers, e.g. depth in cnvkit results.
# from https://unix.stackexchange.com/a/569755
average () {printf '%s\n' 'scale=2' "($*)/$#" | tr ' ' + | bc}