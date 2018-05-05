using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class customdatafieldView extends Ui.DataField {

    hidden var distanceValue;
    hidden var timerValueHours;
    hidden var timerValueMinutes;
    hidden var timerValueSeconds;
    hidden var paceValueMinutes;
    hidden var paceValueSeconds;
    hidden var avgPaceValueMinutes;
    hidden var avgPaceValueSeconds;
    hidden var cadenceValue;
    hidden var hrValue;

    function initialize() {
        DataField.initialize();
        distanceValue = 0.00f;
        timerValueHours = 0;
        timerValueMinutes = 0;
        timerValueSeconds = 0;
        paceValueMinutes = 0;
        paceValueSeconds = 0;
        avgPaceValueMinutes = 0;
        avgPaceValueSeconds = 0;
        cadenceValue = 0;
        hrValue = 0;
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
        
        if(info has :elapsedTime){
        	if(info.elapsedTime != null){
        		var time = (info.elapsedTime * 0.001).toNumber();
        		timerValueHours = (time / 3600).toNumber();
        		timerValueMinutes = ((time % 3600) / 60).toNumber();
        		timerValueSeconds = ((time % 3600) % 60).toNumber();
        	}else{
        		timerValueHours = 0;
        		timerValueMinutes = 0;
        		timerValueSeconds = 0;
        	}
        }
        
        if(info has :currentSpeed){
        	if(info.currentSpeed != null && info.currentSpeed > 0){
        		var timePerMile = (1 / ((info.currentSpeed * 2.23694) / 60));
        		paceValueMinutes = timePerMile.toNumber();
        		paceValueSeconds = ((timePerMile - paceValueMinutes) * 60).toNumber();
        	}else{
        		paceValueMinutes = 0;
        		paceValueSeconds = 0;
        	}
        }
        
        if(info has :averageSpeed){
        	if(info.averageSpeed != null && info.averageSpeed > 0){
        		var avgTimePerMile = (1 / ((info.averageSpeed * 2.23694) / 60));
        		avgPaceValueMinutes = avgTimePerMile.toNumber();
        		avgPaceValueSeconds = ((avgTimePerMile - avgPaceValueMinutes) * 60).toNumber();
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
        
        if(timerValueHours > 0 || timerValueMinutes > 0 || timerValueSeconds > 0){
        	if(timerValueHours > 0){
        		time.setFont(Graphics.FONT_MEDIUM);
        		time.setText(timerValueHours.format("%d")+":"+timerValueMinutes.format("%02d")+":"+timerValueSeconds.format("%02d"));
        	}else{
        		time.setText(timerValueMinutes.format("%d")+":"+timerValueSeconds.format("%02d"));
        	}
        } else{
        	time.setText("0:00");
        }
        
        if(paceValueMinutes > 0 || paceValueSeconds > 0){
        	pace.setText(paceValueMinutes.format("%d")+":"+paceValueSeconds.format("%02d"));
        }else {
        	pace.setText("--:--");
        }
        
        if(avgPaceValueMinutes > 0 || avgPaceValueSeconds > 0){
        	avgPace.setText(avgPaceValueMinutes.format("%d")+":"+avgPaceValueSeconds.format("%02d"));
        }else {
        	avgPace.setText("--:--");
        }
        
		cadence.setText(cadenceValue.format("%d"));
		
        if (hrValue == 0) {
        	hr.setText("--");
        } else {
        	hr.setText(hrValue.format("%d"));
		}
		
        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
