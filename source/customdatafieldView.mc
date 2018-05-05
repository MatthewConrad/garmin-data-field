using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class customdatafieldView extends Ui.DataField {

    hidden var distanceValue = 0.00f;
    hidden var elapsedTime = 0;
    hidden var timerValueHours = 0;
    hidden var timerValueMinutes = 0;
    hidden var timerValueSeconds = 0;
    hidden var paceValueMinutes = 0;
    hidden var paceValueSeconds= 0;
    hidden var avgPaceValueMinutes = 0;
    hidden var avgPaceValueSeconds = 0;
    hidden var cadenceValue = 0;
    hidden var hrValue = 0;

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
        if(info has :elapsedDistance){
        	if(info.elapsedDistance != null){
        		if(System.DeviceSettings.distanceUnits == System.UNIT_STATUTE){
        			distanceValue = info.elapsedDistance * 0.000621371;
        		} else {
        			distanceValue = info.elapsedDistance * 0.001;
        		}
        	}else{
        		distanceValue = 0.00f;
        	}
        }
        
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
        
        if(info has :currentCadence){
        	if(info.currentCadence != null){
        		cadenceValue = info.currentCadence;
        	} else {
        		cadenceValue = 0;
        	}
        }
        
        if(info has :currentHeartRate){
            if(info.currentHeartRate != null){
                hrValue = info.currentHeartRate;
            } else {
                hrValue = 0;
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
    	
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
        
        distance.setText(distanceValue.format("%.2f") + " mi");
        if(distanceValue > 10.0){
        	distance.setFont(Graphics.FONT_MEDIUM);
        }
        
        var timeText;
		if(elapsedTime != null && elapsedTime > 0){
			var seconds = (elapsedTime * 0.001).toNumber();
			timerValueHours = (seconds / 3600).toNumber();
        	timerValueMinutes = ((seconds % 3600) / 60).toNumber();
        	timerValueSeconds = ((seconds % 3600) % 60).toNumber();
        	
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
        }
        pace.setText(paceText);
        
        var avgPaceText;
        if((avgPaceValueMinutes > 0 || avgPaceValueSeconds > 0) && elapsedTime > 10000){
        	avgPaceText = avgPaceValueMinutes.format("%d")+":"+avgPaceValueSeconds.format("%02d");
        }else {
        	avgPaceText = "--:--";
        }
        avgPace.setText(avgPaceText);
        
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
