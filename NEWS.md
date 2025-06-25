# langstats 0.1.0

* Full documentation, from functions (zipf, heaps, zipf_mandelbrot, shannon_entropy, cross_entropy, gain, bow) to datasets (selected_piantadosi, heart_of_darkness)
* Fixes on README.md, and on minor errors over the project
* LICENSE added
* Examples provided

# langstats 0.2.0

What's new?

* Making room to a standard! langstats welcomes a whole standard of data handling across the package, that improves the workflow experience and makes the code more understandable. This is done with input_handling(), and internal function that supports almost all of our functions in the introduction of data in the calculations. Huge deal!
* langstats welcomes n-grams! Seminal tool in Natural Language Processing and Deep Learning that permits to study the combination of words and their ocurrence in the sample. You can access this new feature through the function ngrams(). Easier to use than in quanteda, let me tell you!
* Zipf and Heaps now can be applied to character level studies. This is done with a level argument, like it was previously done with information_theory functions.
