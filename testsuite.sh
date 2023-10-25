#!/bin/bash
mv ./$2 ./$2_bak
N=$3
FILENAME=$1
RESULTS=$2
./purge.sh

for ((i=1; i<=N; i++)); do
    echo "" >> $RESULTS
    echo "Replicate [$i]" >> $RESULTS
    echo "select" >> $RESULTS; echo "" >> $RESULTS
    # select C implementation
    { time ./select "$FILENAME" > "SELECT$i.out"; } 2>> $RESULTS
    ./purge.sh
    #rm o.out

    # awk implementation
    echo "awk" >> $RESULTS; echo "" >> $RESULTS
    { time awk -F'|' '$15 == "RAIL" || (($15 == "AIR" || $15 == "FOB") && $6 < 28955.64)' "$FILENAME" > "AWK$i.out"; } 2>> $RESULTS
    ./purge.sh
    #rm o.out

    # SQLite implementation (15->l_shipmode, 16->l_extendedprice)
    echo "sqlite" >> "$RESULTS"; echo "" >> $RESULTS
    { time sqlite3 <<EOF
.mode csv
.separator "|"
.import "$FILENAME" foo

.output "SQLITE$i.out"
SELECT * FROM foo WHERE (l_shipmode == "RAIL") OR ((l_shipmode == "AIR" OR l_shipmode == "FOB") AND l_extendedprice < 28955.64)
EOF
    } 2>> "$RESULTS"
    #rm o.out
    ./purge.sh
done