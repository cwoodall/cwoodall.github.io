---
layout: post
author: Chris Woodall
title: "How I Manage My Reading List With Trello"
date: 2017-10-16 1:00
comments: true
categories: blog
image: /assets/img/posts/2017-10-16-how-i-manage-my-reading-list-with-trello/trello-reading-list.png
---

In college I frequently would go on book reading binges during breaks, but I could not keep
myself to a consistent schedule to read for pleasure during classes. This "not enough
time" syndrome carried over to after I left college, even though I was not actually 
particularly busy outside of work. Missing reading I started to gather books I wanted
to read, but was having trouble keeping track of all of them, and sorting through what
to read next. So I gave some reason to the madness by using 
[Trello](http://trello.com). You can view my 
[Trello Reading List](https://trello.com/b/9l0rYMxD/reading-list) and see what I
have on there.

Fundamentally by maintaining a list which is so flexible and easy to manipulate I
have added some tangibility to the abstract concept of "books I want to read". I
can also track and set goals related to reading rate and diversity of books since 
I maintain all of that data. Another plus is that it makes it easy to track what
I need to write blurbs for my website. Some of my friends use other systems, 
including [goodreads](https://www.goodreads.com/) and just maintaining a literal
(and literary) stack of books. I like the Trello system because it felt easier to
abandon my reading past, than it did on goodreads, which made it feel like I should
log every book I have read since birth. That said the friends I have who use 
goodreads seem to like it.

Read on for more information on how I organize my Trello reading list.

<!-- more -->

I organize my books into 4 columns:

- `Long List`: Books I want to read, but am less excited about for whatever reason.
- `Short List`: Books I want to read. This includes recommendations from friends,
  podcasts, and things I am excited about.
- `Reading`: Books I am currently reading. I try to keep 1 fiction and 1 non-fiction
   book in here at all times. I find reading fiction helps exercise empathy, and 
   imagination, while non-fiction keeps me excited and engaged with the world around
   me.
- `Finished`: Books I have completed. 

I have experimented with a fifth column `Paused`, which were books that I was 
reading, but stopped for various reasons. I found this to be a distraction and
now I just move `Paused` books into `Short List` keeping them near the top. 
Trello keeps track of every transition, so I can in theory track if the book has
been "paused" or not. When I first started I only had a `Long List`, but I started
to have trouble organizing my interests, so I created the `Short List` as a working
area to sort and categorize books I want to read.

When want to add new books I ask myself: "How excited am I about this
book". If I am very excited I add it to the `Short List`, if I want to record
that I might be interested in it I move the book to `Long List`. I also will put
things I "should" read on the `Short List`. If a friend has lent me a book (less
frequent now with e-readers) I put it on top of the `Short List` so I know to
read it ASAP.

When I am starting a new book I usually look through my `Short List`. 
Sometimes a recommendation or a book being lent by a friend will cause a book to 
skip directly to `Reading`. I try to only read books I am excited about, since 
there are so many books to read. When I am done I move books from `Reading` to 
`Finished`. At this point I try to write a little blurb to post here, and tag it 
with genre and other meta-data for future processing. Periodically, I go through 
my list and will scrub the `Short List`, or move books from the `Long List` to 
`Short List` to keep up with my changing interests. 

One of the biggest benefits is that the Trello document is so flexible and lets me
manage things how I see fit. Initially this seems a little bit silly; but having
that control and freedom has made the book list much more engaging for me. 
Also, the Trello API allows me to write various scripts for analyzing my 
reading habits and the reading list gives me another data list to play around
with. For example I can plot the number of books I have read each month since I
started using Trello to track my book reading:

<center>
<img src="/assets/img/posts/2017-10-16-how-i-manage-my-reading-list-with-trello/books_per_month.png" alt="Books Read Per Month" style="width: 500px;"/>
</center>

Or I could plot the books per month, but ignore the year to look for some trends 
related to when I read the most books! It turns out that I read the most during
the winter months and the least during the summer months. This makes sense since 
I tend to travel for camping, hiking and climbing more during the summer and while
I still travel for ice climbing and skiing lodging tends to be inside so I still
have more time to read during those months. Also curling up with a book is such
a cozy thing.

<center>
<img src="/assets/img/posts/2017-10-16-how-i-manage-my-reading-list-with-trello/books_per_month_all_years.png" alt="Books Read Per Month (All Years)" style="width: 500px;"/>
</center>

I can also plot per year since I started. 2015 was a busy year for my reading! I
need to pick up the pace again!

<center>
<img src="/assets/img/posts/2017-10-16-how-i-manage-my-reading-list-with-trello/books_per_year.png" alt="Books Read Per Year" style="width: 500px;"/>
</center>

To see the code I used to generate these graphs please see this 
[iPython Notebook](https://gist.github.com/cwoodall/9cc9133ad628ea14aabb165f82b7702e).
I utilized python, pandas, trello and matplotlib (with the wonderful 
fivethirtyeight style) to make these graphs! I might coever this in more depth
in a future posting. I hope you find Trello useful if not
for your reading list then for something else.
