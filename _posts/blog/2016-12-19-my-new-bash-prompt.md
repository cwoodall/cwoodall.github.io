---
layout: post
author: Chris Woodall
title: "My New Bash Prompt: Exit Codes, Unicode and Git Branches"
date: 2016-12-19 20:02
comments: true
categories: blog
image: /assets/img/posts/bash-prompt.png
---

I decided to customize my bash prompt. I initially started off with
the following requirements:

1. It should be two lines! I have found that having the input and my prompt on
   one line is not enough space most of the time.
2. I want to see my current git branch, and also if there are any uncommitted
   changes in the current branch.
3. I want to see my username, host name and current directory.
4. The current directory should be truncated so that it shows the 4 closest
   directories in the path.
5. The status if the previous command should be show in some way.

After some work I came up with the prompt shown above. I am excited to keep
using it and customizing it, I am also happy that I decided to use unicode in
the prompt. I have been avoiding unicode in general, but
[Rust](http://www.rustlang.com) has convinced me that I should try to accept
unicode into my life more readily!

After going through the process, here are sometake aways:

1. `printf` supports unicode more reliably than echo. I had some trouble
   getting echo to do what I want to do
2. I always forget this one. Bash functions are never what I think they are.
   They  are  scripts you can define inside of a script. I
   always seem to find this causing problems for me.

I hope you enjoy! Below is the code for my prompt! Put it into you
`.profile`, `.bash_profile` or `.bashrc` file depending on your preference. If
you want to use it.

<!-- more -->

Here is a demonstration video:

![Video of the bash prompt](/assets/img/posts/bash-prompt-video.gif)

<script src="https://gist.github.com/cwoodall/4c277b89a47d970f5a0c4fe59b434f07.js"></script>
