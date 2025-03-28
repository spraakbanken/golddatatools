# What this is

Ongoing work on converting the Eukalyptus corpus to Universal dependencies, carried out by Sasha Berdicevkis at Språkbanken Text, GU. This repo contains the conversion scripts and the current conversion results. Purposes: 1) to create a new Swedish UD corpus; 2) to give the Eukalyptus corpus a new life; 3) to contribute to the harmonization of the Swedish UD treebanks; 4) ultimately, to train a UD model that would add UD annotation to all Språkbanken's corpora.
Thanks to everybody who contributed to the conversion process, especially Gerlof Bouma, Joakim Nivre, Lars Ahrenberg, Arianna Masciolini, Lars Borin, Yvonne Adesam.

# Current stage

As of 2025-03-28: the conversion of POS, features, metadata and MISC is more or less complete (see caveats below). Lemmatization has been somewhat harmonized to match the UD practice better, but that's difficult, because UD does not have any lemmatization guidelines, and the practice for Swedish is not entirely consistent. Syntax has not been converted at all (see below). I have not done anything with tokenization, and I don't think I will (the differences seem to be minor).
Next step: syntax.

# How the conversion works

The Eukalyptus xml files are converted to CONLL-U format (eukxmk_to_conllu.rb). When doing that, I also convert the Eukalyptus trees to dependency trees (so in some sense, the syntax has already been partially converted), but not UD trees. Moreover, I do not check whether the resulting trees are valid (I think in most cases they are, but not always). (Would it have been more efficient to convert using an existing TIGER-to-UD script? Perhaps, but too late for that.) 
Note that the source xml files are ahead of the 1.0.0 version, since we corrected some errors in the process.

# POS-and-feature caveats 
## To be fixed when a UD decree is passed
DET vs PRON vs ADJ, lemmatization of _mycket_ and friends https://github.com/UniversalDependencies/docs/issues/1083
Marking (de)verbal features on participles: https://github.com/UniversalDependencies/docs/issues/1088

## To be fixed when converting syntax
+ SCONJ vs ADP vs ADV and more. Highly polysemous monsters like _som_ and _än_. See https://github.com/UniversalDependencies/docs/issues/1092
+ CCONJ vs ADV. The case of _så_
+ Phrasal verbs (ADV vs ADP for the "particle")
+ MWEs (move some info to Misc?)
+ annotation of _den här_ (head usages), see https://github.com/UniversalDependencies/docs/issues/1083
+ deal with subword-coordination (utvecklings- och garantifonden), the ESM tag

## To be fixed later (manually, or using a fancy LLM, or a really clever heuristic) or not at all
+ VERB vs AUX probably OK for _ha_ and _bli_, but not for other verbs. Manual corrections would be required (+coreference resolution for cases like _Jag kan det_.
+ PROPN is a bit different in UD and Eukalyptus.
+ No distinction between _en_ as a determiner and a numeral
+ some of the Typo=Yes should be Style
+ lemmatization of "andra"
+ PronType=Int,Rel is not disambiguated for _vad, vilken_ etc.
+ ranges (1986-87, 2000-2006, 08.15-09.30) seem to be inconsinsently tokenized. UD policy unknown to me.
