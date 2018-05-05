using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class customdatafieldView extends Ui.DataField {

    hidden var elapsedDistance = 0.00f;
    hidden var elapsedTime = 0;
    hidden var paceValueMinutes = 0;
    hidden var paceValueSeconds= 0;
    hidden var avgPaceValueMinutes = 0;
    hidden var avgPaceValueSeconds = 0;
    hidden var cadenceValue = 0;
    hidden var hrValue = 0;
    hidden var iteration = 0;

    function initialize() {
        DataField.initialize();
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        View.setLayout(Rez.Layouts.MainLayout(dc));
        
        View.findDrawableById("HRLabel").setText("HR");
        View.findDrawableById("TimeLabel").setText("Timer");
        View.findDrawableById("PaceLabel").setText("Pace");
        View.findDrawableById("CadenceLabel").setText("Cadence");
        View.findDrawableById("AvgPaceLabel").setText("Avg. Pace");
        return true;
    }
    
    function convertToMinutesPerUnit(speed){
    	if(System.DeviceSettings.distanceUnits == System.UNIT_STATUTE){
        	return (26.8224 / speed);
        }else{
        	return (16.66667 / speed);
        }
    }
    
    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
    
        elapsedDistance = info.elapsedDistance != null ? info.elapsedDistance : 0.00f;        
        elapsedTime = info.timerTime != null ? info.timerTime : 0;
        
       	if(info has :currentSpeed){
        	if(info.currentSpeed != null && info.currentSpeed > 0){
        		var timePerUnit = convertToMinutesPerUnit(info.currentSpeed);
        		paceValueMinutes = timePerUnit.toNumber();
        		paceValueSeconds = ((timePerUnit - paceValueMinutes) * 60).toNumber();
        	}else{
        		paceValueMinutes = 0;
        		paceValueSeconds = 0;
        	}
        }
        
        if(info has :averageSpeed){
        	if(info.averageSpeed != null && info.averageSpeed > 0){
        		var timePerUnit = convertToMinutesPerUnit(info.averageSpeed);
        		avgPaceValueMinutes = timePerUnit.toNumber();
        		avgPaceValueSeconds = ((timePerUnit - avgPaceValueMinutes) * 60).toNumber();
        	}else{
        		avgPaceValueMinutes = 0;
        		avgPaceValueSeconds = 0;
        	}
        }
        
        cadenceValue = info.currentCadence != null ? info.currentCadence : 0;
        hrValue = info.currentHeartRate != null ? info.currentHeartRate : 0;
        
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
    	// going to use to tell some things when to refresh
    	iteration += 1;
    	
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

        // Set the foreground color and value
        var distance = View.findDrawableById("DistanceValue");
        var time = View.findDrawableById("TimeValue");
        var pace = View.findDrawableById("PaceValue");
        var cadence = View.findDrawableById("CadenceValue");
        var avgPace = View.findDrawableById("AvgPaceValue");
        var hr = View.findDrawableById("HRValue");
        if (getBackgroundColor() == Gfx.COLOR_BLACK) {
            distance.setColor(Gfx.COLOR_WHITE);
            time.setColor(Gfx.COLOR_WHITE);
            pace.setColor(Gfx.COLOR_WHITE);
            cadence.setColor(Gfx.COLOR_WHITE);
            avgPace.setColor(Gfx.COLOR_WHITE);
            hr.setColor(Gfx.COLOR_WHITE);
        } else {
            distance.setColor(Gfx.COLOR_BLACK);
            time.setColor(Gfx.COLOR_BLACK);
            pace.setColor(Gfx.COLOR_BLACK);
            cadence.setColor(Gfx.COLOR_BLACK);
            avgPace.setColor(Gfx.COLOR_BLACK);
            hr.setColor(Gfx.COLOR_BLACK);
        }
        
        var distanceValue = elapsedDistance * 0.001;
        if(System.DeviceSettings.distanceUnits == System.UNIT_STATUTE){
        	distanceValue = distanceValue * 0.000621371;
        }
        distance.setText(distanceValue.format("%.2f") + " mi");
        
        if(distanceValue > 10.0){
        	distance.setFont(Graphics.FONT_MEDIUM);
        }
        
        var timeText;
        var seconds = (elapsedTime * 0.001).toNumber();
		if(elapsedTime != null && elapsedTime > 0){
			var timerValueHours = (seconds / 3600).toNumber();
        	var timerValueMinutes = ((seconds % 3600) / 60).toNumber();
        	var timerValueSeconds = ((seconds % 3600) % 60).toNumber();
        	
        	if(timerValueHours > 0){
        		time.setFont(Graphics.FONT_MEDIUM);
        		timeText = timerValueHours.format("%d")+":"+timerValueMinutes.format("%02d")+":"+timerValueSeconds.format("%02d");
        	}else{
        		timeText = timerValueMinutes.format("%d")+":"+timerValueSeconds.format("%02d");
        	}
        } else{
        	timeText = "0:00";
        }
        time.setText(timeText);
        
        var paceText;
        if(paceValueMinutes > 0 || paceValueSeconds > 0){
        	paceText = paceValueMinutes.format("%d")+":"+paceValueSeconds.format("%02d");
        }else {
        	paceText = "--:--";
        	pace.setText(paceText);
        }
        
        // only update the current pace every 2 seconds
        if(iteration % 2 == 0){
        	pace.setText(paceText);
        }
        
        var avgPaceText;
        if((avgPaceValueMinutes > 0 || avgPaceValueSeconds > 0) && iteration >= 10){
        	avgPaceText = avgPaceValueMinutes.format("%d")+":"+avgPaceValueSeconds.format("%02d");
        }else {
        	avgPaceText = "--:--";
        	avgPace.setText(avgPaceText);
        }
        
        // only update the average pace every 10 seconds
        if(iteration % 10 == 0){
        	avgPace.setText(avgPaceText);
        }
        
		cadence.setText(cadenceValue.format("%d"));
		
		var hrText;
        if (hrValue == 0) {
        	hrText = "--";
        } else {
        	hrText = hrValue.format("%d");
		}
		hr.setText(hrText);
		
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
