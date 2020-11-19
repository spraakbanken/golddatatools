#!/bin/bash
#
source scripts/config.sh

treebank=$1;
short=`bash scripts/treebank_to_shorthand.sh ud $treebank`
lang=`echo $short | sed -e 's#_.*##g'`

test_file=$UDBASE/$treebank/${short}-ud-test.conllu
output_file=$UDBASE/$treebank/${short}-ud-test_lemmatized.conllu

python3 -m stanza.models.lemmatizer --eval_file $test_file --output_file $output_file --gold_file $test_file --lang $lang --mode predict $args
