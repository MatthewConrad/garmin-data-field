# Garmin Data Field
Custom data field to show all of distance, time, pace, average pace, cadence, and HR all in one screen.

### Project Setup
The easiest way to get started with Connect IQ is to use the Eclipse plugin that Garmin provides. Instructions are here: https://developer.garmin.com/connect-iq/sdk/

You may still have to download the SDK for your platform and point Eclipse to it, but the plugin itself provides the emulator and build tools that you'll need.

### Building
Right now the only build target is the Forerunner 735XT, so if you want to build for another device you'll need to add it to `manifest.xml`:

```
...
<iq:products>
  <iq:product id="fr735xt"/>
  <iq:product id="[device id]"/>
</iq:products>
...
```

Once you've added a device to the manifest, you'll be able to select it as a build target when you run the project as a Connect IQ app.

### Installing on your personal device
After you've built the application for your device, it'll create a file called `custom-data-field.prg` (or whatever you've renamed the project to). To install on your watch, copy that file to the `/GARMIN/APPS/` directory on the device.
