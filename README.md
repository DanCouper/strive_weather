# README


## Overview

Web application that displays the weather for the three Strive offices, making 
use of the OpenWeatherMap API (API key + office locations provided in test).

## Setup Notes

I am *not* focussing on deployment best practices here, nor am I emulating an
existing older codebase. This is outside the scope of the task.

| Tool  | Version |
| ----- | ------- |
| Ruby  | 3.2.2   |
| Rails | 7.1.2   |

There is an API key provided for the [Open Weather Map](openweathermap.org/) API.

Note that this is for the free tier, which provides access to:

1. [the current weather at a location](https://openweathermap.org/current), and
2. [a 5-day forecast](https://openweathermap.org/forecast5) (which provides the forecast in 3-hour intervals).

To set up and run the application, assuming the specified Ruby version is 
installed, `cd` into this project directory, and run:

```
gem install
```

Followed by:

```
rails server
```

This should start a rails server at http://127.0.0.1:3000

## Initial steps

- [ ] Initialise basic minimal Rails install.
- [ ] Add Open Weather Map API key to the Rails user config secrets.
- [ ] Add simple functional sketch of service object that hits Open Weather Map API.
- [ ] Dump the data into the app:
    - [ ] Add a route (`weathertest`)
    - [ ] Add a controller that calls the OWM API & grabs data.
    - [ ] Add a view that displays that data on an HTML page.
