using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class customdatafieldView extends Ui.DataField {

	hidden var elapsedDistance = 0;
	hidden var lapStartDistance = 0;
	hidden var lapDistance = 0;
    hidden var elapsedTime = 0;
    hidden var lapStartTime = 0;
    hidden var lapTime = 0;
    hidden var currentSpeed = 0;
    hidden var lapSpeed = 0;
    hidden var averageSpeed = 0;
    hidden var paceValueMinutes = 0;
    hidden var paceValueSeconds= 0;
    hidden var lapPaceValueMinutes = 0;
    hidden var lapPaceValueSeconds = 0;
    hidden var avgPaceValueMinutes = 0;
    hidden var avgPaceValueSeconds = 0;
    hidden var cadenceValue = 0;
    hidden var hrValue = 0;
    hidden var iteration = 0;

    function initialize() {
        DataField.initialize();
    }
        
    function convertToMinutesPerUnit(speed){
    	if(System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE){
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
    
        elapsedDistance = info.elapsedDistance != null ? info.elapsedDistance : 0;
        elapsedTime = info.timerTime != null ? info.timerTime : 0;
        lapDistance = elapsedDistance - lapStartDistance;
        lapTime = elapsedTime - lapStartTime;
        currentSpeed = info.currentSpeed != null ? info.currentSpeed : 0;
        lapSpeed = lapDistance > 0 ? lapDistance / lapTime : 0;
        averageSpeed = info.averageSpeed != null ? info.averageSpeed : 0;     
        cadenceValue = info.currentCadence != null ? info.currentCadence : 0;
        hrValue = info.currentHeartRate != null ? info.currentHeartRate : 0;
        
    }
    
    function onTimerLap(){
    	lapStartDistance = elapsedDistance;
    	lapStartTime = elapsedTime;
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
    	// going to use to tell some things when to refresh
    	iteration += 1;
    	
    	var width = dc.getWidth();
    	var height = dc.getHeight();
    	
    	var backgroundColor = getBackgroundColor();
    	var valueColor = backgroundColor == Graphics.COLOR_WHITE ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE;
    	var labelColor = backgroundColor == Graphics.COLOR_WHITE ? Graphics.COLOR_DK_GRAY : Graphics.COLOR_LT_GRAY;
    	var valueSize = Graphics.FONT_LARGE;
    	var labelSize = Graphics.FONT_TINY;
    	
    	var distanceYPosition = (height > 214) ? height * .04 : height * .03;
    	var distanceSize = (height > 214) ? Graphics.FONT_MEDIUM : Graphics.FONT_LARGE; 
    	
        // Set the background color
        dc.setColor(backgroundColor, backgroundColor);
        dc.fillRectangle(0, 0, width, height);
        
        // Draw grid
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(0, height * .2, width, height * .2);
        dc.drawLine(0, height * .5, width, height * .5);
        dc.drawLine(0, height * .8, width, height * .8);
        dc.drawLine(width * .5, height * .2, width * .5, height * .8);
        
        // this is going up here because we're gonna shift some stuff based on distance
        var distanceValue = elapsedDistance * 0.001;
        if(System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE){
        	distanceValue = elapsedDistance * 0.000621371;
        }
        
        var distanceLabelX = (distanceValue > 10.0) ? width * .675 : width * .6375;
        var distanceXPosition = (distanceValue > 10.0) ? width / 2 : width * .4625;
        
        // Draw Labels
        dc.setColor(labelColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(distanceLabelX, height * .0725, labelSize, "mi", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width * .25, height * .22, labelSize, "Timer", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width * .75, height * .22, labelSize, "Pace", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width * .25, height * .52, labelSize, "Avg. Pace", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width * .75, height * .52, labelSize, "Lap Pace", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width * .33, height * .82, labelSize, "HR", Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(valueColor, Graphics.COLOR_TRANSPARENT);
                
        dc.drawText(distanceXPosition, distanceYPosition, valueSize, distanceValue.format("%.2f"), Graphics.TEXT_JUSTIFY_CENTER);
        
        var timeText;
        var seconds = (elapsedTime * 0.001).toNumber();
		if(elapsedTime != null && elapsedTime > 0){
			var timerValueHours = (seconds / 3600).toNumber();
        	var timerValueMinutes = ((seconds % 3600) / 60).toNumber();
        	var timerValueSeconds = ((seconds % 3600) % 60).toNumber();
        	
        	if(timerValueHours > 0){
        		timeText = timerValueHours.format("%d")+":"+timerValueMinutes.format("%02d")+":"+timerValueSeconds.format("%02d");
        		dc.drawText(width * .25, height * .31, Graphics.FONT_MEDIUM, timeText, Graphics.TEXT_JUSTIFY_CENTER);
        	}else{
        		timeText = timerValueMinutes.format("%d")+":"+timerValueSeconds.format("%02d");
        		dc.drawText(width * .25, height * .31, valueSize, timeText, Graphics.TEXT_JUSTIFY_CENTER);
        	}
        } else{
        	timeText = "0:00";
        	dc.drawText(width * .25, height * .315, valueSize, timeText, Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        var paceText;
  		    
        if(currentSpeed > 0){
        	if(iteration <= 2 || iteration % 2 == 0){
        		var timePerUnit = convertToMinutesPerUnit(currentSpeed);
        		paceValueMinutes = timePerUnit.toNumber();
        		paceValueSeconds = ((timePerUnit - paceValueMinutes) * 60).toNumber();
        	}
        	
        	var tooSlowImperial = (System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE) && paceValueMinutes > 15;
        	var tooSlowMetric = (System.getDeviceSettings().distanceUnits == System.UNIT_METRIC) && paceValueMinutes > 9;
        	
        	if(tooSlowImperial || tooSlowMetric) {
        		paceText = "--:--";
        	} else {
        		paceText = paceValueMinutes.format("%d")+":"+paceValueSeconds.format("%02d");
        	}
        }else {
        	paceText = "--:--";
        }
        
        dc.drawText(width * .75, height * .315, valueSize, paceText, Graphics.TEXT_JUSTIFY_CENTER);
        System.println("Pace: " + currentSpeed);
        
		var lapPaceText;
		var lapDistance = elapsedDistance - lapStartDistance;
		var lapTime = (elapsedTime - lapStartTime) / 1000;
		if(lapDistance > 0){
			if(iteration % 10 == 0){
				var lapSpeed = lapDistance / lapTime;
				System.println("Lap Pace: " + lapSpeed);
				var timePerUnit = convertToMinutesPerUnit(lapSpeed);
				lapPaceValueMinutes = timePerUnit.toNumber();
				lapPaceValueSeconds = ((timePerUnit - lapPaceValueMinutes) * 60).toNumber();
			}
			lapPaceText = lapPaceValueMinutes.format("%d")+":"+lapPaceValueSeconds.format("%02d");
		}else {
			lapPaceText = "--:--";
		}
		
		dc.drawText(width * .75, height * .615, valueSize, lapPaceText, Graphics.TEXT_JUSTIFY_CENTER);
        
        var avgPaceText;
        if(averageSpeed > 0){
        	if(iteration % 10 == 0){
        		var timePerUnit = convertToMinutesPerUnit(averageSpeed);
        		avgPaceValueMinutes = timePerUnit.toNumber();
        		avgPaceValueSeconds = ((timePerUnit - avgPaceValueMinutes) * 60).toNumber();
        	}
        	avgPaceText = avgPaceValueMinutes.format("%d")+":"+avgPaceValueSeconds.format("%02d");
        }else {
        	avgPaceText = "--:--";
        }
        
		dc.drawText(width * .25, height * .615, valueSize, avgPaceText, Graphics.TEXT_JUSTIFY_CENTER);
		System.println("Avg. Pace " + averageSpeed);
		
		var hrText;
        if (hrValue == 0) {
        	hrText = "--";
        } else {
        	hrText = hrValue.format("%d");
		}
		dc.drawText(width / 2, height * .82, valueSize, hrText, Graphics.TEXT_JUSTIFY_CENTER);

    }

}
