---
layout: default
title: Christopher Woodall - Home
header: true
---

## Who am I?


I am an electrical and embedded systems engineer, rock climber, musician and a life
long learner. Currently I work in the sprouting robotics industry in the Boston,
Massachusetts area, but am a New York native.

I catalogue my personal projects at
[Happy Robot Labs](http://www.happyrobotlabs.com)  with a
focus on open source hardware and software, where applicable. To me sharing
my projects is important as it helps encourage others in the community
to work on the ideas that float through their minds. I also maintain a curated
[portfolio](/portfolio) and
[Github](http://www.github.com/cwoodall).

When I am not tinkering or working I am climbing rocks,
[playing the mandolin](/music), or
[reading](/reading)

## Latest Articles

{% for entry in site.categories.blog limit:4 %}
- [{{entry.title}}]({{entry.url}})
{%endfor%}

## Featured Projects

{% for entry in site.categories.portfolio limit:4 %}
- [{{entry.title}}](/portfolio/#portfolio_{{entry.id}})
{%endfor%}

## Recently Read

{% for entry in site.categories.reading limit:4 %}
- [{{entry.title}}]({{entry.url}})
{%endfor%}
