from flair.data import Sentence, Corpus
from flair.datasets import ColumnCorpus
from flair.models import SequenceTagger
from flair.embeddings import TokenEmbeddings, WordEmbeddings, FlairEmbeddings, StackedEmbeddings #, CharacterEmbeddings
from typing import List
from pathlib import Path
import torch

torch.cuda.empty_cache()

embedding_types: List[TokenEmbeddings] = [

    WordEmbeddings('sv'),

    # comment in this line to use character embeddings
    # CharacterEmbeddings(),

    FlairEmbeddings('sv-forward'),
    FlairEmbeddings('sv-backward'),
]

embeddings: StackedEmbeddings = StackedEmbeddings(embeddings=embedding_types)

columns = {0: 'text', 1: 'pos'}

data_folder = "data"

corpus: Corpus = ColumnCorpus(data_folder, columns,
                              train_file='suc3.col2',
                              test_file='talbanken_test.col2',#,
                              dev_file='talbanken_dev.col2')
tag_type = 'pos'

tag_dictionary = corpus.make_tag_dictionary(tag_type=tag_type)

tagger: SequenceTagger = SequenceTagger(hidden_size=256,
                                        embeddings=embeddings,
                                        tag_dictionary=tag_dictionary,
                                        tag_type=tag_type,
                                        use_crf=True)

from flair.trainers import ModelTrainer

#if starting training use this line and comment out the next two
trainer: ModelTrainer = ModelTrainer(tagger, corpus)

# if resuming training use these lines and comment out the previous one
#checkpoint = "model1/checkpoint.pt"
#trainer = ModelTrainer.load_checkpoint(checkpoint, corpus)

trainer.train('user_model',
              learning_rate=0.1,
              mini_batch_size=16,
              max_epochs=150,
              train_with_dev=True,
              checkpoint=True, #stores the model after every epoch
              embeddings_storage_mode='none') #should be faster if set to gpu, but then cuda runs out of memory. Probably a bug