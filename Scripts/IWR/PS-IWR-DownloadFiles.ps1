
$urls = @(
    "https://cdn.anychart.com/releases/v8/js/anychart-base.min.js"
    "https://cdn.anychart.com/releases/v8/js/anychart-graph.min.js"
    "https://cdn.anychart.com/releases/v8/js/anychart-data-adapter.min.js"
    "https://cdn.anychart.com/releases/v8/js/anychart-ui.min.js"
    "https://cdn.anychart.com/releases/v8/js/anychart-exports.min.js"
    "https://cdn.anychart.com/releases/v8/themes/dark_blue.min.js"
    "https://cdn.anychart.com/releases/v8/css/anychart-ui.min.css"
    "https://cdn.anychart.com/releases/v8/fonts/css/anychart-font.min.css"
)


foreach ($url in $urls) {
    $name = $url -split "/" | select -last 1
    (iwr -uri $url).content | out-file $name
}

