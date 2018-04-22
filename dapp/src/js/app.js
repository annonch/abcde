App = {
    web3Provider: null,
    contracts: {},
    account: '0x0',
    //hasVoted: false,

    init: function() {
	return App.initWeb3();
    },

    initWeb3: function() {
	// TODO: refactor conditional
	if (typeof web3 !== 'undefined') {
	    // If a web3 instance is already provided by Meta Mask.
	    App.web3Provider = web3.currentProvider;
	    web3 = new Web3(web3.currentProvider);
	} else {
	    // Specify default instance if no web3 instance provided
	    App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
	    web3 = new Web3(App.web3Provider);
	}
	return App.initContract();
    },

    initContract: function() {
	$.getJSON("Master.json", function(master) {
	    // Instantiate a new truffle contract from the artifact
	    App.contracts.Master = TruffleContract(master);
	    // Connect provider to interact with contract
	    App.contracts.Master.setProvider(App.web3Provider);

	    //App.listenForEvents();

	    return App.render();
	});
    },

    
    // Listen for events emitted from the contract
    listenForEvents: function() {
	App.contracts.Master.deployed().then(function(instance) {
	    // Restart Chrome if you are unable to receive this event
	    // This is a known issue with Metamask
	    // https://github.com/MetaMask/metamask-extension/issues/2393
	    instance.LogPriceUpdated({}, {
		fromBlock: 0,
		toBlock: 'latest'
	    }).watch(function(error, event) {
		console.log("event triggered", event)
		// Reload when a new vote is recorded
		App.render();
	    });
	});
    },
    
    render: function() {
	var quotesInstance;
	var queryCount = 1;
	var loader = $("#loader");
	var content = $("#content");

	console.log("here0");
	
	loader.show();
	content.hide();
	//loader.hide();
	//content.show();


	
	console.log("here1");
	// Load account data
	web3.eth.getCoinbase(function(err, account) {
	    if (err === null) {
		App.account = account;
		$("#accountAddress").html("Your Account: " + account);
	    }
	});


	console.log("here2");
	// Load contract data
	App.contracts.Master.deployed().then(function(instance) {
	    quotesInstance = instance;
	    console.log("here2.1");
	    return quotesInstance.getAAPLQuote();//queryCount();
	}).then(function(getAAPLQuote) {
	    return quotesInstance.AAPL_q();//();//getAAPLQuote();//queryCount();
	}).then(function(AAPL_q) { //getAAPLQuote) {
	    console.log("here2.2 " + AAPL_q);
	    content.hide();
	    loader.show();

	    var quotesResults = $("#quotesResults");
	    quotesResults.empty();

	    var quotesSelect = $('#quotesSelect');
	    quotesSelect.empty();

	    
	    for (var i = 1; i <= queryCount; i++) {
		//quotesInstance.prices(i).then(function(AAPLprices) {
		var asset = "AAPL";
		//var name = candidate[1];
		var price = AAPL_q;//getAAPLQuote;//quotesInstance.getAAPLQuote().then(function(getAAPLQuote){//candidate[2];
		
		// Render quotes Result
		var quotesTemplate = "<tr><th>" + asset +  "</td><td>" + price + "</td></tr>"
		quotesResults.append(quotesTemplate);
		
		// Render candidate ballot option
		var quotesOption = "<option value='" + asset + ".l" + "' >" + "buy  (long) " + asset + " Margin Req: " + price / 5  + "  Expiry: June </ option>"
		quotesSelect.append(quotesOption);
		
		var quotesOption = "<option value='" + asset + ".s"  + "' >" + "sell (short) " + asset + " Margin Req: " + price / 5  + "  Expiry: June </ option>"
		quotesSelect.append(quotesOption);
		//});
	    }
	    //return quotesInstance.voters(App.account);
	    //}).then(function(hasVoted) {
	    // Do not allow a user to vote
	    //if(hasVoted) {
	    //$('form').hide();
	    //}

	    console.log("here4");
	    
	    loader.hide();
	    content.show();
	    }).catch(function(error) {
	    console.warn(error);
	});
    },
    
    buy: function(price) {
	//var price = AAPL_q;
	var candidateId = $('#quotesSelect').val();
	var pos = -1;
	if (candidateId === "AAPL.s") {
	    pos = 1;
	}
	if (candidateId === "AAPL.l") {
	    pos = 0;
	}
	console.log(candidateId,pos);
	var price;
	App.contracts.Master.deployed().then(function(instance) {
            quotesInstance = instance;
	    
            return quotesInstance.AAPL_q();//(pos, { from: App.account, value:price/5 });
        }).then(function(AAPL_q) {
            // Wait for votes to update
	    price = AAPL_q;
	});


	App.contracts.Master.deployed().then(function(instance) {
	    quotesInstance = instance;

	    return quotesInstance.Match(pos, { from: App.account, value:price/5 });
	}).then(function(Match) {
	    // Wait for votes to update
	    $("#content").hide();
	    $("#loader").show();
	}).catch(function(err) {
	    console.error(err);
	});
    }

};

$(function() {
    $(window).load(function() {
	App.init();
    });
});
