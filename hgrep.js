#!/usr/bin/env node

var usage = "hgrep        -- Search and extract elements from html\n\n" +
"Usage:\n" +
"    hgrep [-a <attr> | -t | -v] [-x] [-r <range>] <selector> [<filter>]\n" +
"    hgrep -h | --help\n" +
"\n" +
"Options:\n" +
"    -h --help   Show this message.\n" +
"    <selector>  Cheerio selector, e.g. 'table.wiki tr'\n" +
"    -r <range>  Use specified range of selection, e.g. 0, 0:2, -1\n" +
"    <filter>    Descendant selector to filter selection\n" +
"    -a <attr>   Output value of attribute <attr> of selection\n" +
"    -x          Suppress empty attributes\n" +
"    -t          Output text content of selection\n" +
"    -v          Output input document after removing selection\n";

var $$ = require("cheerio"),
    opts = require("docopt").docopt(usage, {argv: process.argv.slice(2)}, usage);

require("readtoend").readToEnd(process.stdin, function(err, data) {
    var $ = $$.load(data),
        sel = $(opts["<selector>"]);

    if (opts["<filter>"]) {
        /* Filter by descendant selector */
        sel = sel.filter(function(i, el) {
            return $$(el).find(opts["<filter>"]).length !== 0;
        });
    }
    if (opts["-r"]) {
        /* Reduce selection to desired range */
        var comps = opts["-r"].split(":");
        if (comps.length === 2) {
            var begin = +comps[0],
                end = (comps[1] === '') ? undefined : +comps[1],
                len = sel.length;

            if (begin < 0) {
                begin += len;
            }
            if (end < 0) {
                end += len;
            }
            if (begin < 0 || end < 0 || begin >= len || end > len ||
                begin >= end ) {
                console.error("Invalid range");
                process.exit(2);
            }

            sel = sel.slice(+comps[0], comps[1] === '' ? undefined : +comps[1]);
        } else {
            sel = sel.eq(+comps[0]);
        }
    }
    if (opts["-v"]) {
        sel.remove();
        console.log($.html());
    } else if (sel.length === 0) {
        process.exit(1);
    } else if (opts["-a"] || opts["-t"]) {
        var out = sel.toArray().map(function(e) {
            var ret = opts["-a"] ? $$(e).attr(opts["-a"]) : $$(e).text().trim();
            if (!opts["-x"] && (ret === null || ret === undefined)) {
                ret = "";
            }
            return ret;
        }).filter(function(e) { return e !== undefined && e !== null; });
        console.log(out.join("\n"));
    } else {
        console.log($$.html(sel));
    }
    process.exit(0);
});
