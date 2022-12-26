#!/bin/bash

FILES=`find -regex '.*\.\(cpp\|h\)' | grep -v '.*/\..*'`

clang-tidy $FILES --format-style=file --quiet $* > clang-tidy-report.txt

#cppcheck --enable=all --std=c++11 --language=c++ --output-file=cppcheck-report.txt *


WE_CLANG=`grep -e 'warning: ' -e 'error: ' clang-tidy-report.txt | wc -l`

if [ $WE_CLANG -ne 0 ] 
then
    echo "Clang-tidy errors:"
    cat clang-tidy-report.txt
    echo "checks-failed=1" >> $GITHUB_OUTPUT
else
    echo "checks-failed=0" >> $GITHUB_OUTPUT
fi

echo "Total comments: " $WE_CLANG

exit $WE_CLANG
