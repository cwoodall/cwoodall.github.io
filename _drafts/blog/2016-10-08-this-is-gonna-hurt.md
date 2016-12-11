---
layout: post
author: Chris Woodall
title: "You Might Want To Sit Down: Don't Be Sarcastic In Your Official Documentation"
date: 2016-11-11 12:00
comments: true
categories: blog
---

About a month ago I was writing a [post on an Option type for C++][option-post]. At one point I came across the "Most Vexing Parse", getting bizarre error messages for something which I thought was well defined. The piece of code in question was:


```c++
int main() {
  Option<int> foo(Nothing());
  printf("%d", foo.unwrap_or(0));
}
```

Which yields the wonderful and descriptive error message in `g++`:

```
divide.cpp: In function ‘int main()’:
divide.cpp:15:20: error: request for member ‘unwrap_or’ in ‘bar’, which is of non-class type ‘Option<int>(Nothing (*)())’
   printf("%d", bar.unwrap_or(0));
```

`clang++` is a little more helpful:

```
divide.cpp:13:18: warning: parentheses were disambiguated as a function
      declaration [-Wvexing-parse]
  Option<int> bar(Nothing());
                 ^~~~~~~~~~~
divide.cpp:13:19: note: add a pair of parentheses to declare a variable
  Option<int> bar(Nothing());
                  ^
                  (        )
divide.cpp:15:19: error: member reference base type 'Option<int>
      (Nothing (*)())' is not a structure or union
  printf("%d", bar.unwrap_or(0));
               ~~~^~~~~~~~~~
```

This I found out results from an ambiguity in the C++ parser. What I wanted to do was create an `Option<int>` using a temporary `Nothing` instance. Instead, confusion ensues. The parser thinks that a function declaration might be happening, and this ambiguity is resolved by assuming it is a function declaration. No error will occur until you try to use `bar` as an instance of `Option<int>`.

Scott Meyer terms this "the most vexing parse" and for good reason. During my research I uncovered the [ISO C++ FAQ response][iso-cpp-faq] to a question about parse most vexing. And what ensues is an sarcastic and aggravated assault on anyone who does not understand the arcane knowledge which makes C++ work. They say: "This is really going to hurt; you might want to sit down".

I will admit the FAQ answer is funny. But it strongly smells of programmer humor, and I belong to that tribe. But, I think when we write our documentation we should be more respectful of those reading. I am not calling for an end of humorous books like [Why's Poignant Guide][poignant], or [Learn You A Haskell][haskell], but I am saying we should be inclusive. It is not the humor itself which is upsetting, it is the way it is employed to make the reader feel like they did something wrong. It is meant to alienate those who would question or misunderstand the "Most vexing parse". The implication is that "clearly it is not the language designers fault, it is yours for not implicitly understanding that this is a silly thing to do". It comes off as defensive, not welcoming or educational.

As I work on various projects, in the open (and in private) I want to commit to writing inclusive and understandable documentation. I may employ humor here or there, but never should it be employed to alienate the reader. I have a lot of respect for those who can boil down complex information and explain it to an eager and willing learner without insulting the learners intelligence. That is my goal, and I hope it is yours too.

<!-- more -->

_P.S._ I really do love the more humorous programming books and blog posts that have been written. However, I tend to find it best when they are not sources of authority alienating the reading, and instead making learning a fun and creative act! Let's aim for this.

[haskell]: http://learnyouahaskell.com/
[poignant]: http://poignant.guide/
[option-post]: http://cwoodall.com/blog/2016/10/10/cpp-option.html
[iso-cpp-faq]: https://isocpp.org/wiki/faq/ctors#fn-decl-vs-obj-instantiation
