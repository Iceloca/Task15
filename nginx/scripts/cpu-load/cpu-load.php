<?php
function getCpuLoad(): float {
    $output = shell_exec("mpstat 1 1 | grep 'Average: *all' | awk '{print 100 - $11}'");
    return floatval(trim($output));
}

echo getCpuLoad() . "\n";
