#!/bin/bash

# compare output with python duplicate remover and common wordlists

set -v

# `gtimeout` fallback for old macos/xcode
timeout=timeout
which $timeout &>/dev/null || timeout=gtimeout

DUPLICUT="./duplicut"
COMPARATOR="./test/scripts/remove-duplicates.py"

WORDLIST_DIR="./test/wordlists"

function print_info () {
    echo -e "\033[1;34m[*]\033[0;36m $1\033[0m"
}
function print_good () {
    echo -e "\033[1;32m[+]\033[0;32m $1\033[0m"
}
function print_bad () {
    echo -e "\033[1;31m[-]\033[0;31m $1\033[0m"
}

function test_wordlist ()
{
    file="$WORDLIST_DIR/$1"
    shift 1
    args="$@"
    rm -f nonreg_*.out
    rm -f nonregdupes_*.out
    p="[CMP] duplicut $args < $file:"

    $timeout 5 $DUPLICUT -o nonreg_duplicut.out -D nonregdupes_duplicut.out -m 64K $args < $file
    retval="$?"
    $COMPARATOR $file -o nonreg_comparator.out -D nonregdupes_comparator.out $args
    if [[ -f nonregdupes_duplicut.out ]]; then
        sort -o nonregdupes_duplicut.out nonregdupes_duplicut.out
        sort -o nonregdupes_comparator.out nonregdupes_comparator.out
    fi

    if [[ $retval -eq 124 ]]; then
        print_bad "$p timeout"
        exit 1
    elif ! diff -q nonreg_*.out 2>&1 > /dev/null; then
        print_bad "$p different result (nonreg)"
        diff -y <(cat -te nonreg_comparator.out) <(cat -te nonreg_duplicut.out)
        print_bad "Run \`diff nonreg_*.out\` to see differences"
        exit 1
    elif ! diff -q nonregdupes_*.out 2>&1 > /dev/null; then
        print_bad "$p different result (nonregdupes)"
        diff -y <(cat -te nonregdupes_comparator.out) <(cat -te nonregdupes_duplicut.out)
        print_bad "Run \`diff nonregdupes_*.out\` to see differences"
        exit 1
    else
        print_good "$p OK !"
    fi
}

WORDLISTS=$(find "$WORDLIST_DIR" -maxdepth 1 -type f  \
    -name '*.txt' -exec basename {} ';' | sort)

for wordlist in $WORDLISTS; do
    for size in 1 5 14 15 40 65 128 2000 4095; do
        test_wordlist "$wordlist" -l $size
        test_wordlist "$wordlist" -l $size -p
        test_wordlist "$wordlist" -l $size -c
        test_wordlist "$wordlist" -l $size -p -c
        test_wordlist "$wordlist" -l $size -C
        test_wordlist "$wordlist" -l $size -p -C
    done
done

rm -f nonreg_*.out
