---
layout: post
author: Chris Woodall
title: "You Might Want To Sit Down: Don't Be Sarcastic In Your Official Documentation"
date: 2016-11-11 16:00
comments: true
categories: blog
---

About a month ago I was having trouble with a piece of code. I was getting an error message for something I thought was well-defined. This was while I was working on my [piece][option-post] on an Option type for C++. The piece of code in question was:


```c++
int main() {
  Option<int> a(Nothing());
}
```

This I found out results in an error in the C++ parser. What I wanted to do was create an `Option<int>` using a temporary `Nothing` instance. Instead, confusion ensues, the parser things maybe they wanted to call a function: `a(Nothing bar)`. Scott Meyer terms this "the most vexing parse" and for good reason, in C++ the safe solution is to call it a day and go home. During my research I uncovered the [ISO C++ FAQ response][iso-cpp-faq] to a question about parse most vexing. And what ensues is an sarcastic and aggravated assault on anyone who does not understand the arcane knowledge which makes C++ work. They say in fact that, "This is really going to hurt; you might want to sit down".

I will admit the FAQ answer is funny. But it strongly smells of programmer humor, and I belong to that tribe. But I think when we write our documentation, especially in the official repository of knowledge for our language, we should be more respectful of those reading. We should be inclusive of those who might not understand the jokes. It is not the humor itself which is upsetting, it is the way it is employed to make the reader feel like they did something wrong. It is meant to alienate those who would question the "Most vexing parse". Clearly it is not the language designers fault, it is yours for not implicitly understanding that this is a silly thing to do (and then print out a unhelpful error message). It comes off as defensive, not welcoming or educational.

As I work on various projects, in the open (and behind closed doors) I want to commit to writing inclusive and understandable documentation. I may employ humor here or there, but never should it be employed to alienate the reader. I have a lot of respect for those who can boil down complex information and explain it to an eager and willing learner without insulting the learners intelligence. That is my goal, and I hope it is yours too.

[option-post]: link

[iso-cpp-faq]: https://isocpp.org/wiki/faq/ctors#fn-decl-vs-obj-instantiation
