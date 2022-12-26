#!/bin/bash

if [[ -z "$GITHUB_TOKEN" ]]; then
	echo "The GITHUB_TOKEN is required."
	exit 1
fi

clang-tidy ./*.cpp --format-style=file --quiet --export-fixes=clang-tidy-output.yml $*

clang-tidy ./*.cpp --format-style=file --quiet $* > clang=tidy-report.txt

cppcheck --enable=all --std=c++11 --language=c++ --output-file=cppcheck-report.txt *

PAYLOAD_CLANG=`cat clang-tidy-report.txt`
PAYLOAD_CPPCHECK=`cat cppcheck-report.txt`
COMMENTS_URL=$(cat $GITHUB_EVENT_PATH | jq -r .pull_request.comments_url)
  
echo $COMMENTS_URL
echo "Clang errors:"
echo $PAYLOAD_CLANG
echo "Cppcheck errors:"
echo $PAYLOAD_CPPCHECK
OUTPUT=$'**CLANG WARNINGS**:\n'
OUTPUT+=$'\n```\n'
OUTPUT+="$PAYLOAD_CLANG"
OUTPUT+=$'\n```\n'

OUTPUT+=$'\n**CPPCHECK WARNINGS**:\n'
OUTPUT+=$'\n```\n'
OUTPUT+="$PAYLOAD_CPPCHECK"
OUTPUT+=$'\n```\n' 

PAYLOAD=$(echo '{}' | jq --arg body "$OUTPUT" '.body = $body')

curl -s -S -H "Authorization: token $GITHUB_TOKEN" --header "Content-Type: application/vnd.github.VERSION.text+json" --data "$PAYLOAD" "$COMMENTS_URL"
