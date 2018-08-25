function HCUniversalDJ() {};



// ----------   Global variables    ---------- 
HCUniversalDJ.deck={
	'[Channel1]': 1,
	'[Channel2]': 2
};

// ----------   Functions    ----------

// called when the MIDI device is opened & set up
HCUniversalDJ.init = function(id, debugging) {	
	HCUniversalDJ.id = id;

	HCUniversalDJ.allLedOff();
	HCUniversalDJ.readFaders();

	// Switch-on some LEDs for improve the usability
	// midi.sendShortMsg(0x90, 46, 0x7F);	// Automix LED
	// midi.sendShortMsg(0x90, 14, 0x7F);	// Cue deck A LED
	// midi.sendShortMsg(0x90, 34, 0x7F);	// Cue deck B LED
	print ("***** Hercules Universal DJ Control id: \""+id+"\" initialized.");
};

// Called when the MIDI device is closed
HCUniversalDJ.shutdown = function(id) {
	HCUniversalDJ.allLedOff();
	print ("***** Hercules Universal DJ Control id: \""+id+"\" shutdown.");	
};


HCUniversalDJ.allLedOff = function () {
	// Switch off all LEDs
	// All deck A + 9 generic
	for(led=1;led<95;led++) {
		midi.sendShortMsg(0x90,led,0);
	}
	// All deck B
	for(led=1;led<86;led++) {
		midi.sendShortMsg(0x91,led,0);
	}
	// Deck A and B total VU meter off
	midi.sendShortMsg(0x90,105,0);
	midi.sendShortMsg(0x91,105,0);
};

HCUniversalDJ.readFaders = function () {
	// reset/resend all fader values
	midi.sendShortMsg(0xB0,127,00);
};

HCUniversalDJ.wheelTouch = function (channel, control, value, status,group) {
    var deck=HCUniversalDJ.deck[group];
    if (value == 0x7F && !engine.isScratching(deck)) {
       var alpha = 1.0/8;
       var beta = alpha/32;
       engine.scratchEnable(deck, 128, 33+1/3, alpha, beta);
       print ("start scratch on "+deck);
    } else {
       engine.scratchDisable(deck);
       print ("stop scratch on "+deck);
    }

};

HCUniversalDJ.wheelScratch = function (channel, control, value, status,group) {
	var deck=HCUniversalDJ.deck[group];
	if(!engine.isScratching(deck)) return;
	var newValue;
	if (value-64 > 0)
		newValue = value-128;
	else
		newValue = value;
	engine.scratchTick(deck,newValue);
};

HCUniversalDJ.setMode = function (channel, control, value, status,group) {
       print ("setmode on "+group);
};
