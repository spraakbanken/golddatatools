from flair.data import Sentence, Corpus
from flair.datasets import ColumnCorpus
from flair.models import SequenceTagger
import time

columns = {0: 'text', 1: 'pos'}

data_folder = "data"

corpus: Corpus = ColumnCorpus(data_folder, columns,
                              train_file='suc3.col2',
                              test_file='talbanken_test.col2',
                              dev_file='talbanken_dev.col2')

tagger = SequenceTagger.load("flair_full/final-model.pt")

f2 = open('talbanken_test_tagged_by_flair.col2', 'w', encoding="utf-8")

start_time = time.time()

# change to UTF-8, normal output
for sentence in corpus.test:
    tagger.predict(sentence)
    for token in sentence:
        tag = token.get_tag("pos")
        token1 = str(token)
        #print(token)
        f2.write(f'{token1.split(" ")[2]}\t{tag.value}\t{tag.score}\n')
    f2.write("\n")

elapsed_time1 = time.time() - start_time    

print("Elapsed time:")
print(elapsed_time1)