# symmetrical-octo-spoon

This is a quick experiment to make sure we can create a geofence around a point, and once the user leaves the location, we can save a record, even if the app is backgrounded. 

The app itself is fairly simple and presents a view with a single button. When the user taps the button, the app saves a region (circular with its center in the best approximation of the current location, usually down to less than 20 feet). When the user leaves the region, we record the event, and we present it on the same view. 

Currently, to keep things simple, we store the region using KVC to the user defaults. In the main app, this would be the internal DB. 

The feature depends on the user granting full access to the location services, not just when the app is running. 

In order to test, we can simply run the app on a real device, or we can use the simulator spoofing locations. Either way, we will need a known location to save the region and full access to location services.
