#!/usr/bin/php
<?php
#
# Centers a text file based on the longest line.
#
# Usage: ./centertree.php file.txt
#
$f = array_map("trim", file($argv[1]));
$width = max(array_map("strlen", $f));
foreach($f as $l)
    echo str_repeat(" ", ($width - strlen($l)) / 2).$l."\n";
