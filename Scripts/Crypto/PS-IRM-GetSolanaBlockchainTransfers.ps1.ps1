#Using AnyChart to render network/transaction graph

function Get-SolanaBlockchainTransfers {
    param (
        [String]$TokenAccount,
        [String]$File,
        [Switch]$OpenFile,
        [Switch]$ShowDetails,
        [String]$TransactionsOutFile
    )
    $Headers = @{
        accept = 'application/json'
    }

    $ids = @()
    $Transactions = @()
    $TransactionsDetailed = @()

    $Url = 'https://public-api.solscan.io/account/transactions?account='+$TokenAccount
    $Response = Invoke-RestMethod -Uri $Url -Method Get

    foreach ($item in $Response) {
       
       $Url = 'https://public-api.solscan.io/transaction/'+$($item.txHash)
       #$Url
       $Response = Invoke-RestMethod -Uri $Url -Method Get

       if($($Response.tokenTransfers.source_owner) -ne $null){
        $ids += [string]$($Response.tokenTransfers.source_owner)
        $ids += [string]$($Response.tokenTransfers.destination_owner)
        $Transactions += "{from: '"+$($Response.tokenTransfers.source_owner)+"', to:'"+$($Response.tokenTransfers.destination_owner)+"'},"
        $TransactionsDetailed += "From:$($Response.tokenTransfers.source_owner);To:$($Response.tokenTransfers.destination_owner);TransactionId:$($item.txHash)"
      }
       
    }

    $ids0 = $ids | sort -Unique
    $nodesArray = @()

    foreach ($id in $ids0) {
        $nodesArray += "{id:'"+$id+"', height: '10', fill: '#6497b1'},"
    }

    $nodes = $nodesArray
    $edges = $Transactions

    $htmlCode = "
    <html>
    <head>
        <style>
#container {
    width: 100%;
    height: 100%;
    margin: 0;
    padding: 0;
}
        </style>
    </head>
    <body>

<div id='anychart-embed-tYmxv98v' class='anychart-embed anychart-embed-tYmxv98v'>
<script src='https://cdn.anychart.com/releases/v8/js/anychart-core.min.js'></script>
<script src='https://cdn.anychart.com/releases/v8/js/anychart-graph.min.js'></script>
<script src='https://cdn.anychart.com/releases/v8/js/anychart-exports.min.js'></script>
<script src='https://cdn.anychart.com/releases/v8/js/anychart-ui.min.js'></script>
<!-- <div id='ac_style_tYmxv98v' style='display:none;'>
html, body, #container {
    width: 100%;
    height: 100%;
    margin: 0;
    padding: 0;
}
</div>-->
<script>(function(){
function ac_add_to_head(el){
	var head = document.getElementsByTagName('head')[0];
	head.insertBefore(el,head.firstChild);
}
function ac_add_link(url){
	var el = document.createElement('link');
	el.rel='stylesheet';el.type='text/css';el.media='all';el.href=url;
	ac_add_to_head(el);
}
function ac_add_style(css){
	var ac_style = document.createElement('style');
	if (ac_style.styleSheet) ac_style.styleSheet.cssText = css;
	else ac_style.appendChild(document.createTextNode(css));
	ac_add_to_head(ac_style);
}
ac_add_link('https://cdn.anychart.com/releases/v8/css/anychart-ui.min.css');
ac_add_link('https://cdn.anychart.com/releases/v8/fonts/css/anychart-font.min.css');
ac_add_style(document.getElementById('ac_style_tYmxv98v').innerHTML);
ac_add_style('.anychart-embed-tYmxv98v{width:600px;height:450px;}');
})();</script>
<div id='container'></div>
<script>
    anychart.onDocumentReady(function() {

  // create data
  var data= {
    'nodes':[
    "+$nodes+"
    ],

    'edges':[
    "+$edges+"
    ]}

  var chart = anychart.graph(data);

  chart.title('Solana Blockchain - Transactions');

  // configure nodes
  chart.nodes().labels().enabled(true);
  chart.nodes().labels().fontSize(12);

  chart.nodes().normal().fill('white');
  chart.nodes().normal().stroke('1 black');
  chart.nodes().shape('circle');

  chart.nodes().hovered().fill('white');
  chart.nodes().hovered().stroke('2 black');
  chart.nodes().hovered().shape('circle');

  chart.layout().type('force');

  // initiate drawing the chart
  chart.container('container').draw();
});
</script>
</div>

    </body>
</html>
"

    $htmlCode | out-file -FilePath "$($file)" -Encoding utf8 -force

    if($TransactionsOutFile){
        $TransactionsDetailed | out-file -FilePath "$($TransactionsOutFile)" -Encoding utf8 -force
    }
    if($ShowDetails){
        $TransactionsDetailed
    }
    if($OpenFile){
        explorer.exe "$($file)"
    }

}

#Lets look at the Kevin Token 9SLCSSkEYL9YbKtAvw39xNzMEV4a7oLisGXhSJt73UCu ... its not that big...
Get-SolanaBlockchainTransfers -TokenAccount 9SLCSSkEYL9YbKtAvw39xNzMEV4a7oLisGXhSJt73UCu -file TokenNetworkGraph.html -OpenFile -ShowDetails -TransactionsOutFile Transactions.csv

