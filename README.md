# Traffic data integration for Inhuman Insurance, Inc.

This robot is integrates the road traffic fatality rate API and the insurance sales system that needs the data for finding the best sales targets.

The producer:

* Downloads the raw traffic data.
* Transforms the raw data into a business data format.
* Saves the business data as work items that can be consumed later.

The consumer:

* Loops all the work items one by one.
* Validates the data.
* Posts the data to the sales system API.
* Handles successful responses.
* Handles application exceptions.
* Handles business exceptions.