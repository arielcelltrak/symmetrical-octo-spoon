# symmetrical-octo-spoon

This is a quick experiment to make sure we can create a geofence around a point, and once the user leaves the location, we can save a record, even if the app is backgrounded. 

The app itself is fairly simple and presents a view with a single button. When the user taps the button, the app saves a region (circular with its center in the best approximation of the current location, usually down to less than 20 feet). When the user leaves the region, we record the event, and we present it on the same view. 

Currently, to keep things simple, we store the region using KVC to the user defaults. In the main app, this would be the internal DB. 

The feature depends on the user granting full access to the location services, not just when the app is running. 

In order to test, we can simply run the app on an actual device or use the simulator spoofing locations. Either way, we will need a known place to save the region and full access to location services.

## Setup and modules
In order to keep it as simple as possible, and to be able to deploy thinking about backward compatibility, we are not using any third-party dependency. 

We rely on Core Location, and, up to some point, on User Notifications. 

Fortunately, Core Location is one of the few services that will wake up an app, even if that was killed. 

Specifically for geofences, we can register up to [20 regions](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423656-startmonitoringforregion), defined with a center, and a radius. The regions can be deleted as well, so we can manage the stock of available regions (if needed). 

When we enter (or leave) a region, the Core Location will notify us, either through a delegate (if the app is active, or only backgrounded) or through the app delegate (when the app has been killed previously). In the latter, we will need to restart the Core Location service and ask for a new location fix. Core Location will return the new fix and the region that we are either entering or leaving. 

We will need to enable Background Modes (Location and Background Processing), to notify the system we want to wake up in the event of a significant change in location. 

```
	<key>UIBackgroundModes</key>
	<array>
		<string>location</string>
		<string>processing</string>
	</array>
```

As explained before, we also need full access to core location services. We will need to ask our users for access to Location services "always" and not just when the app is in use. We will need to add a new value to the info.plist, `NSLocationAlwaysAndWhenInUseUsageDescription` which is a string explaining why we need to have access to the location service at all times. 

In our Location Manager [we enforce](https://github.com/arielcelltrak/symmetrical-octo-spoon/blob/b12e586f4c225370da0d6139b4251491281fe75f/SymmetricalOctoSpoon/SymmetricalOctoSpoon/LocationManager.m#L37) the permission, presenting the settings if needed. 

### App Delegate
The app Delegate is pretty simple, we just boot the Location Manager, and set up Local Notifications (we have a category to handle that). 

### Location Manager
The Location Manager is, perhaps, the most interesting class. 

Internally, it sets itself as the delegate of the CLLocationManager. We expose a singleton, and we use Notification Center and User Notifications to broadcast changes in locations and permissions. 

### View Controller
A really simple view controller containing just two views, a button, and a label. The button is used to instruct the Location Manager to start monitoring a region centered around our current location. And when we leave it, we refresh the content of the label with information about the region. 
