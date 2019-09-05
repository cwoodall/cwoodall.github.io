---
layout: default
title: Christopher Woodall - Home
header: true
---

## Who am I?

I am an electrical and embedded software engineer, rock climber, musician and a life
long learner. Check otu my [now](/now) page to learn more about what I am up to right now.
When I am not tinkering or working I am climbing rocks, [playing the mandolin](/music), or
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
