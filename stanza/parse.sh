#!/bin/bash
#
source scripts/config.sh

treebank=$1;

short=`bash scripts/treebank_to_shorthand.sh ud $treebank`
lang=`echo $short | sed -e 's#_.*##g'`

test_file=$UDBASE/$treebank/${short}-ud-test.conllu
output_file=$UDBASE/$treebank/${short}-ud-test_parsed.conllu

#args=$@


python3 -m stanza.models.parser --wordvec_dir $WORDVEC_DIR --eval_file $test_file --output_file $output_file --gold_file $test_file --lang $lang --shorthand $short --mode predict $args
