# hgrep - search HTML with CSS selectors

> Some people, when confronted with an HTML parsing problem, think, "I know,
> I'll use hgrep!" Now they have -1 problems.

**hgrep** is a Unix CLI tool which lets you select elements with jQuery/CSS
syntax and print the HTML serialization of the selection, or its text
representation, or a specified attribute of each element.

For example, to print all the story links from the HN front page:

    curl -s https://news.ycombinator.com | hgrep -a href ".athing .title > a"

Print the list of subreddits featuring on the Reddit front page:

    curl -s https://www.reddit.com | hgrep -t ".sitetable a.subreddit"


## Installation

Install the last published version from npm:

    npm install -g hgrep

Install from this directory:

    npm install -g

Testing:

    npm install
    npm test

## Background

HTML cannot be parsed with regular expressions, as the nearest [Stack Overflow
guru](http://stackoverflow.com/a/1732454/3515576) will be happy to inform you.
Coding to a parser API is too much trouble for simple use cases. Besides, the
best, most user-friendly APIs are available in the form of
[jQuery](https://jquery.com/) in the browser and a jQuery-like NodeJS library,
[Cheerio](https://github.com/cheeriojs/cheerio).

**hgrep** is a simple CLI wrapper around
[Cheerio](https://github.com/cheeriojs/cheerio), and enables the use of
familiar jQuery/CSS selectors to **grep** through HTML on the command line. It
is based on the [pigshell](http://pigshell.com) command of the same name.

Detailed usage is documented below.

hgrep(1) -- search HTML with CSS selectors
==========================================

## SYNOPSIS

    hgrep [-a <attr> | -t | -v] [-r <range>] <selector> [<filter>]
    hgrep -h | --help

## DESCRIPTION

**hgrep** searches an HTML document or fragments read from standard input for
elements matching a given condition, specified as a jQuery/CSS-like
`<selector>`. The list of selected elements is optionally filtered by another
selector which specifies constraints on their descendants and is then reduced
to an optional range. By default, the selection is serialized to HTML and
written to standard output. Alternately, a specified attribute of each element
in the selection may be output.

The following parameters are available:

  * `<selector>`: Specifies the elements to be selected in a jQuery/CSS-style
    format as implemented by [cheerio](https://github.com/cheeriojs/cheerio),
    which uses [css-select](https://github.com/fb55/css-select). Custom
    selectors of note include `:contains`, which can be used to specify what
    text contents the desired elements must have.

  * `<filter>`: Selector which specifies conditions to be met
    by the descendants of the elements specified by `<selector>`. This enables
    specifications like "select all `<tr>`s which have `<a>` elements
    containing 'Follow User' in the link text". Note that the output will be a
    list of `<tr>` elements.

  * `-r <range>`:
    Specifies the range of elements found by the `<selector>`/`<filter>` to be
    considered.  `<range>` can be a number indicating a single element at the
    given offset from the beginning of the list. Negative numbers represent
    offsets from the end of the list, with -1 being the last element.
    Alternately, a range of the form `start:end` specifies elements with offset
    from `start` through `end-1`, where `start` and `end` can be negative
    numbers. `start` must be strictly less than `end`. Finally, `start:`
    specifies elements from `start` to the end of the list.

  * `-a <attr>`: Output one line containing the `<attr>` attribute for each
    selected element. Blank lines are output for elements which lack the
    specified attribute, unless the `-x` flag is specified.

  * `-x`: In the `-a` case, do not output blank lines for elements which
    lack the specified attribute.

  * `-t`: Output the text contents of each selected element, rather than the
    elements themselves. The text is trimmed of whitespace at both ends.

  * `-v`: Output the input document with all selected elements removed.

## DIAGNOSTICS

**hgrep** exits with 0 if a match was found, and 1 if no match was found.
In case the input document was malformed or the specifier syntax is incorrect,
**hgrep** exits with a non-zero value.

## EXAMPLES

The examples below use the [Hacker News](https://news.ycombinator.com) home
page.

Get all the links

    curl -s https://news.ycombinator.com | hgrep -a href a

Get only story links

    curl -s https://news.ycombinator.com | hgrep -a href ".athing .title > a"

Get all the story titles

    curl -s https://news.ycombinator.com | hgrep -t ".athing .title > a"

Convert the HN front page stories into tab-separated values

    curl -s https://news.ycombinator.com > hn.html
    cat hn.html | hgrep -t ".athing .title > a" > title
    cat hn.html | hgrep -a href ".athing .title > a" > link
    cat hn.html | hgrep -t .subtext | sed -ne 's/^\([0-9][0-9]*\) points.*/\1/p;t' -e 's/.*//p' > points
    paste title link points > hn.tsv

The examples below use the [Wikipedia world population](https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population) page.

    url="https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population"

Output HTML for the first data row of the table:

    curl -s $url | hgrep -r 1 "table.wikitable tr"

Output HTML for rows containing the word "Island"

    curl -s $url | hgrep "table.wikitable tr" "td:contains(Island)" 

Print text contents of 2nd column of each row, one line per row

    curl -s $url | hgrep -t "table.wikitable td:nth-child(2)"

Strip first 3 columns of the table:

    curl -s $url | hgrep "table.wikitable" | hgrep -v "td:nth-child(-n+2)"

## SEE ALSO

[cheerio](https://github.com/cheeriojs/cheerio), [css-select](https://github.com/fb55/css-select)
