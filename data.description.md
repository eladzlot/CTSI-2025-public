# Data description

The following table describes the variables in [data/fears.csv](fears.csv).
The data are composed from the raw data in the `raw` folder by `scripts/compose.R`.

Variable        | Type          | Description
--------------- | ------------- | -----------------
id              | factor        | Unique user id
experiment      | factor        | Experiment name
type            | factor        | "core" or "superficial"  
wave            | numeric       | Chronological number of measurement. 1 for first measurement 2 for second measurement.
fear            | string        | The full text of the core or surface threat
motivation1_1   | factor        | Motivation 1 for judge 1
motivation1_2   | factor        | Motivation 1 for judge 2
motivation2_1   | factor        | Motivation 2 for judge 1
motivation2_2   | factor        | Motivation 2 for judge 2
