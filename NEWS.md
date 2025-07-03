# langstats v0.1.0

* Full documentation, from functions (zipf, heaps, zipf_mandelbrot, shannon_entropy, cross_entropy, gain, bow) to datasets (selected_piantadosi, heart_of_darkness)
* Fixes on README.md, and on minor errors over the project
* LICENSE added
* Examples provided

# langstats v0.2.0

What's new?

* Making room to a standard! langstats welcomes a whole standard of data handling across the package, that improves the workflow experience and makes the code more understandable. This is done with input_handling(), an internal function that supports almost all of our functions in the introduction of data in the calculations. Huge deal!
* langstats welcomes n-grams! Seminal tool in Natural Language Processing and Deep Learning that permits to study the combination of words and their ocurrence in the sample. You can access this new feature through the function ngrams(). Easier to use than in quanteda, let me tell you!
* Zipf and Heaps now can be applied to character level studies. This is done with a level argument, like it was previously done with information_theory functions.

# langstats v0.3.0

What's new?

* Collocations G^2 tests support! We now offer a function to conduct hypothesis testing on word collocations, and even to conduct exploratory reports on which bigrams are more statistically significant in a text. All powered by the ngrams() already avalaible function.

* Minor typos and errors in documentation and workflow protocols fixed.

# langstats v0.4.0

What's new?

* `input_handling()` now supports neural tokenisation using HuggingFace's BERT tokenizer via `reticulate`. Use `token = "transformer"` for more accurate, context-aware word splitting (e.g., handling subwords, contractions, punctuation). By the way, the default remains `token = "regex"` for speed use.

* With this new feature, it comes a new necessity: importing `transformers` and `torch`. The package automatically loads Python dependencies via `reticulate::import()`. Users must install `transformers` and `torch` in a 64-bit Python environment!
