---
layout: post
author: Chris Woodall
title: "Installing libsvm For Use With GNU Octave In Ubuntu 14.04"
date: 2016-11-19 20:00
comments: true
categories: blog
#image:
---

For week 7 of the [Coursera][coursera] [Machine Learning][coursera-ml] course we
learned about [Support Vector Machines (SVM)][svm-wiki]. SVMs are a useful and
powerful tools for solving classification problems. They can be tailored to
solve complicated classification boundaries, and don't suffer from some of the
down sides of optimizing [neural networks][nn-wiki]. One of the
example problems uses an SVM to classify spam emails. A SVM implementation
written in MATLAB/Octave is used, but for further work [libsvm][libsvm] (or
another SVM library) is recommended. To get `libsvm` working with Octave in
Ubuntu 14.04 there are a few steps that are not obvious. I did not find very
many instructions so I compiled the steps I followed to get a stable Octave
environment with `libsvm`. Read on for details.

<!-- more -->

### Installation

Before starting you will need a working installation of Octave (I used 3.8.1)
which can be installed using `apt` if you are on Ubuntu 14.04. You will
also need the `liboctave-dev` package:

```
$ sudo apt-get install octave liboctave-dev
```

Now, you should navigate to the directory you want to keep `libsvm`
in. This directory should not change. I used the [Github][libsvm-github]
repository of `libsvm`, but you can also use the [source release][lib-svm-link]
for a stable release:

```
$ git clone https://github.com/cjlin1/libsvm.git
```

Next make the C library and the Octave/Matlab library (note `>>>` indicates
the Octave shell):


```
$ cd libsvm
$ make
$ cd matlab
$ octave
>>> make
```

Finally, you need to add the directory you made `libsvm` in to your Octave path.
To do this you can use the `addpath()` function in Octave, followed by the
`savepath()` function. When you add the path it should be an absolute path, so
that it always works. The `pwd` Octave function will return the current
directory we are in. So after running `make` from within Octave I suggest using
the commands below:

```
>>> addpath(pwd())
>>> savepath()
```

Congratulations, you have installed `lisvm` and added it to your path. You
should be able to run `svmtrain` and `svmpredict`. You should be able to get
the help information for `svmtrain`:

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
[nn-wiki]: https://en.wikipedia.org/wiki/Artificial_neural_network
[libsvm]: http://www.csie.ntu.edu.tw/~cjlin/libsvm/
[libsvm-github]: http://www.csie.ntu.edu.tw/~cjlin/cgi-bin/libsvm.cgi?+http://www.csie.ntu.edu.tw/~cjlin/libsvm+tar.gz
[lib-svm-link]: https://github.com/cjlin1/libsvm
