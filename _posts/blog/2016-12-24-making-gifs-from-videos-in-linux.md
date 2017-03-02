---
layout: post
author: Chris Woodall
title: "Making GIFs From Videos in Linux"
date: 2016-12-23 18:02
comments: true
categories: blog
image: /assets/img/posts/test-rust-led-blink.gif
---

I started making some `.gif`s to embed in documentation and my notes as I
develop **[Rusty Nail][rusty-nail]**. I always have to lookup how to
convert the images to `gif`s. Everytime I am also concerned with how big the
`.gif`s are so after doing some looking around I made a little script which
uses `ffmpeg`, `convert`, and `gifsicle` (with `giflossy`) to take an input
`mp4`, `webm`, or any video that ffmpeg can decode.

The process is this:

1. `ffmpeg` splits the video into a directory of `gif`s
2. `convert` those images and stitches them together into one `gif`.
3. `gifsicle` optimizes the `gif` and allow a stage to resize it and also change
   the color. The `giflossy` plug-in also can apply lossy compression to the
   gif video during the optimization step.

Read on for the script.

<!-- more -->

## Requirements:

To use my `make_gif.sh` script you will need the following applications:

1. ffmpeg (I used version 3.1.5)
2. Imagemagick (ImageMagick 6.9.3-0 Q16 x86_64 2016-05-14)
3. [gifsicle][gifsicle]
4. [giflossy][giflossy]: Which you will need to install from source.

These should be installable from Ubuntu 16.04 or Fedora 25.

## The Script

<script src="https://gist.github.com/cwoodall/8db0acd49f059c58424f3d736b99b999.js"></script>

## Usage

```shell-session
$ make_gif.sh -o my_new_image.gif input_file.mp4
```

You can get help information with:

```shell-session
$ make_gif.sh -h
```

This was my first time using the _POSIX_ `getopts` which made it pretty easy to
add new options to the script. I far prefer the style of
[clap-rs](https://github.com/kbknapp/clap-rs) (for Rust), or
[click](http://click.pocoo.org/5/) for Python.

## Conclusion

While `gif`s are a pretty useful format for adding video content to
documentation. I realize that the `.webm` format might be a better alternative,
in the long run. With less effort you can get higher compression rates and
smaller file sizes, all with better quality and the option for integrating
audio.

## Resources:

- [This AskUbuntu Post](http://askubuntu.com/questions/648603/create-gif-animated-image-from-mp4-video)
- [The giflossy website](https://kornel.ski/lossygif)

[gifsicle]: https://www.lcdf.org/gifsicle/
[giflossy]:  https://github.com/pornel/giflossy
[rusty-nail]: https://github.com/cwoodall/rusty-nail
