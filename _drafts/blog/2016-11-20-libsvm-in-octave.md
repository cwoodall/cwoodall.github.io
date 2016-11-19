---
layout: post
author: Chris Woodall
title: "Installing and Using `libsvm` From Within GNU Octave"
date: 2016-11-20 10:00
comments: true
categories: blog
#image:
---

For week 7 of the [Coursera][coursera] [Machine Learning][coursera-ml] course we
learned about [Support Vector Machines (SVM)][svm-wiki]. SVMs are a useful and
powerful tools for solving classification problems. They can be tailored to
solve complicated classification boundaries, and don't suffer from some of the
down sides of optimizing [neural networks][nn-wiki]. In the course, one of the
example problems is using the SVM to classify spam emails. A SVM implementation
written in MATLAB/Octave is used, but later on it is recommended to use a more
powerful and optimized SVM implemented called [libsvm][libsvm]. Getting this
working with Octave on Ubuntu 14.04 was rather straightforward, but I did not
find any instructions. Read on for a quick walkthrough for `libsvm`
installation.

<!-- more -->

### Installation

First you will need to have Octave installed and also install `liboctave-dev`
which will install the octave header files which are needed to compile the
`libsvm` bindings. So from a terminal:

```
sudo apt-get install octave liboctave-dev
```

Now, you should navigate to a directory you want to keep the compiled `libsvm`
in. This will become the home of `libsvm` where we will download it. I use the
[Github][libsvm-github] repository for `libsvm`, but you can also use the
[source release][lib-svm-link]:

```
git clone https://github.com/cjlin1/libsvm.git
```

Next make the C library:

```
cd libsvm
make
```

And finally the Octave/Matlab library (note `>>>` indicates typing into the
Octave shell):

```
cd matlab
octave
>>> make
```

Finally you need to add it to your Octave path I suggest the following method,
which will add it permanently to your Octave distribution:

```
>>> libsvm_dir = pwd;
>>> addpath(libsvm_dir)
>>> savepath()
```

Congratulations, you should be able to get the help information for `svmtrain`
and `svmpredict` now.

```
>>> svmtrain
Usage: model = svmtrain(training_label_vector, training_instance_matrix, 'libsvm_options');
libsvm_options:
-s svm_type : set type of SVM (default 0)
	0 -- C-SVC		(multi-class classification)
	1 -- nu-SVC		(multi-class classification)
	2 -- one-class SVM
	3 -- epsilon-SVR	(regression)
	4 -- nu-SVR		(regression)
-t kernel_type : set type of kernel function (default 2)
	0 -- linear: u'*v
	1 -- polynomial: (gamma*u'*v + coef0)^degree
	2 -- radial basis function: exp(-gamma*|u-v|^2)
	3 -- sigmoid: tanh(gamma*u'*v + coef0)
	4 -- precomputed kernel (kernel values in training_instance_matrix)
-d degree : set degree in kernel function (default 3)
-g gamma : set gamma in kernel function (default 1/num_features)
-r coef0 : set coef0 in kernel function (default 0)
-c cost : set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)
-n nu : set the parameter nu of nu-SVC, one-class SVM, and nu-SVR (default 0.5)
-p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1)
-m cachesize : set cache memory size in MB (default 100)
-e epsilon : set tolerance of termination criterion (default 0.001)
-h shrinking : whether to use the shrinking heuristics, 0 or 1 (default 1)
-b probability_estimates : whether to train a SVC or SVR model for probability estimates, 0 or 1 (default 0)
-wi weight : set the parameter C of class i to weight*C, for C-SVC (default 1)
-v n : n-fold cross validation mode
-q : quiet mode (no outputs)
```

[coursera]: http://coursera.com/
[coursera-ml]: https://www.coursera.org/learn/machine-learning/home
[svm-wiki]: https://en.wikipedia.org/wiki/Support_vector_machine
[nn-wiki]: https://en.wikipedia.org/wiki/Artificial_neural_network1
[libsvm]: http://www.csie.ntu.edu.tw/~cjlin/libsvm/
[libsvm-github]: http://www.csie.ntu.edu.tw/~cjlin/cgi-bin/libsvm.cgi?+http://www.csie.ntu.edu.tw/~cjlin/libsvm+tar.gz
[lib-svm-link]: https://github.com/cjlin1/libsvm
