using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class customdatafieldView extends Ui.DataField {

	hidden var elapsedDistance = 0;
    hidden var elapsedTime = 0;
    hidden var currentSpeed = 0;
    hidden var averageSpeed = 0;
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
        currentSpeed = info.currentSpeed != null ? info.currentSpeed : 0;
        averageSpeed = info.averageSpeed != null ? info.averageSpeed : 0;     
        cadenceValue = info.currentCadence != null ? info.currentCadence : 0;
        hrValue = info.currentHeartRate != null ? info.currentHeartRate : 0;
        
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
    	
        // Set the background color
        dc.setColor(backgroundColor, backgroundColor);
        dc.fillRectangle(0, 0, width, height);
        
        // Draw grid
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(0, 35, width, 35);
        dc.drawLine(0, height / 2, width, height / 2);
        dc.drawLine(0, 145, width, 145);
        dc.drawLine(width / 2, 35, width / 2, 145);
        
        // Draw Labels
        dc.setColor(labelColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(53, 40, labelSize, "Timer", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(162, 40, labelSize, "Pace", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(53, 95, labelSize, "Cadence", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(162, 95, labelSize, "Avg. Pace", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(75, 152, labelSize, "HR", Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(valueColor, Graphics.COLOR_TRANSPARENT);
        
        var distanceValue = elapsedDistance * 0.001;
        if(System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE){
        	distanceValue = elapsedDistance * 0.000621371;
        }
        
        if(distanceValue > 10.0){
        	dc.drawText(width / 2, 0, Graphics.FONT_MEDIUM, distanceValue.format("%.2f") + " mi", Graphics.TEXT_JUSTIFY_CENTER);
        }else{
        	dc.drawText(width / 2, 0, valueSize, distanceValue.format("%.2f") + " mi", Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        var timeText;
        var seconds = (elapsedTime * 0.001).toNumber();
		if(elapsedTime != null && elapsedTime > 0){
			var timerValueHours = (seconds / 3600).toNumber();
        	var timerValueMinutes = ((seconds % 3600) / 60).toNumber();
        	var timerValueSeconds = ((seconds % 3600) % 60).toNumber();
        	
        	if(timerValueHours > 0){
        		timeText = timerValueHours.format("%d")+":"+timerValueMinutes.format("%02d")+":"+timerValueSeconds.format("%02d");
        		dc.drawText(53, 54, Graphics.FONT_MEDIUM, timeText, Graphics.TEXT_JUSTIFY_CENTER);
        	}else{
        		timeText = timerValueMinutes.format("%d")+":"+timerValueSeconds.format("%02d");
        		dc.drawText(53, 54, valueSize, timeText, Graphics.TEXT_JUSTIFY_CENTER);
        	}
        } else{
        	timeText = "0:00";
        	dc.drawText(53, 54, valueSize, timeText, Graphics.TEXT_JUSTIFY_CENTER);
        }
        
        var paceText;
  		    
        if(currentSpeed > 0){
        	if(iteration <= 2 || iteration % 2 == 0){
        		var timePerUnit = convertToMinutesPerUnit(currentSpeed);
        		paceValueMinutes = timePerUnit.toNumber();
        		paceValueSeconds = ((timePerUnit - paceValueMinutes) * 60).toNumber();
        	}
        	paceText = paceValueMinutes.format("%d")+":"+paceValueSeconds.format("%02d");
        }else {
        	paceText = "--:--";
        }
        
        dc.drawText(162, 54, valueSize, paceText, Graphics.TEXT_JUSTIFY_CENTER);
        
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
        dc.drawText(162, 109, valueSize, avgPaceText, Graphics.TEXT_JUSTIFY_CENTER);
        
		dc.drawText(53, 109, valueSize, cadenceValue.format("%d"), Graphics.TEXT_JUSTIFY_CENTER);
		
		var hrText;
        if (hrValue == 0) {
        	hrText = "--";
        } else {
        	hrText = hrValue.format("%d");
		}
		dc.drawText(width / 2, 147, valueSize, hrText, Graphics.TEXT_JUSTIFY_CENTER);

    }

}
