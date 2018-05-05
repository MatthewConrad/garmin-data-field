using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class customdatafieldView extends Ui.DataField {

    hidden var distanceValue;
    hidden var hrValue;

    function initialize() {
        DataField.initialize();
        distanceValue = 0.00f;
        hrValue = 0.0f;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        View.setLayout(Rez.Layouts.MainLayout(dc));
        var labelView = View.findDrawableById("label");
        var valueView = View.findDrawableById("value");

//        View.findDrawableById("DistanceLabel").setText("Distance");
        View.findDrawableById("HRLabel").setText("HR");
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        if(info has :currentHeartRate){
            if(info.currentHeartRate != null){
                hrValue = info.currentHeartRate;
            } else {
                hrValue = 0.0f;
            }
        }
        
        if(info has :elapsedDistance){
        	if(info.elapsedDistance != null){
        		System.println(info.elapsedDistance);
        		distanceValue = info.elapsedDistance * 0.000621371;
        	}else{
        		distanceValue = 0.00f;
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
        var hr = View.findDrawableById("HRValue");
        if (getBackgroundColor() == Gfx.COLOR_BLACK) {
            distance.setColor(Gfx.COLOR_WHITE);
            hr.setColor(Gfx.COLOR_WHITE);
        } else {
            distance.setColor(Gfx.COLOR_BLACK);
            hr.setColor(Gfx.COLOR_BLACK);
        }
        distance.setText(distanceValue.format("%.2f") + " mi");
        hr.setText(hrValue.format("%d"));

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
